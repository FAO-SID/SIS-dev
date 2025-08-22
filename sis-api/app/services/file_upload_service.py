import os
import uuid
import pandas as pd
import numpy as np
from pathlib import Path
from typing import Dict, List, Any, Tuple
from fastapi import HTTPException, UploadFile
from sqlalchemy import text, create_engine, MetaData, Table, Column
from sqlalchemy.orm import Session
from sqlalchemy.types import String, Integer, Float, Boolean, Date
from app.core.config import settings
from app.models.api_models import UploadedDataset, UploadedDatasetColumn


class FileUploadService:
    def __init__(self, db: Session):
        self.db = db
        self.upload_dir = Path(settings.UPLOAD_DIR)
        self.upload_dir.mkdir(exist_ok=True)
        
    async def process_uploaded_file(
        self, 
        file: UploadFile, 
        user_id: str, 
        project_id: str = None
    ) -> Dict[str, Any]:
        """
        Process uploaded Excel or CSV file and create table in soil_data_upload schema
        """
        # Validate file extension
        file_extension = Path(file.filename).suffix.lower()
        if file_extension not in settings.ALLOWED_EXTENSIONS:
            raise HTTPException(
                status_code=400,
                detail=f"File type {file_extension} not allowed. Allowed types: {settings.ALLOWED_EXTENSIONS}"
            )
        
        # Check file size
        content = await file.read()
        if len(content) > settings.max_file_size_bytes:
            raise HTTPException(
                status_code=400,
                detail=f"File size exceeds maximum allowed size of {settings.MAX_FILE_SIZE_MB}MB"
            )
        
        # Save file temporarily
        file_id = str(uuid.uuid4())
        temp_filename = f"{file_id}_{file.filename}"
        temp_file_path = self.upload_dir / temp_filename
        
        try:
            with open(temp_file_path, "wb") as f:
                f.write(content)
            
            # Read file into pandas DataFrame
            df = self._read_file_to_dataframe(temp_file_path, file_extension)
            
            # Generate table name
            table_name = self._generate_table_name(file.filename)
            
            # Analyze data types and structure
            analysis = self._analyze_dataframe(df)
            
            # Create table in soil_data_upload schema
            self._create_table_in_database(df, table_name, analysis)
            
            # Insert data into the table
            self._insert_data_to_table(df, table_name)
            
            # Create uploaded_dataset record
            uploaded_dataset = UploadedDataset(
                table_name=table_name,
                individual_id=user_id,
                project_id=project_id,
                file_name=file.filename,
                status="Uploaded",
                n_rows=len(df),
                n_col=len(df.columns),
                has_cords=self._detect_coordinates(df),
                cords_epsg=4326 if self._detect_coordinates(df) else None
            )
            self.db.add(uploaded_dataset)
            
            # Create column records
            for col_name in df.columns:
                column_record = UploadedDatasetColumn(
                    table_name=table_name,
                    column_name=col_name
                )
                self.db.add(column_record)
            
            self.db.commit()
            
            # Clean up temp file
            temp_file_path.unlink()
            
            # Return response data
            return {
                "message": "File uploaded and processed successfully",
                "table_name": table_name,
                "file_name": file.filename,
                "n_rows": len(df),
                "n_cols": len(df.columns),
                "columns": list(df.columns),
                "data_types": analysis["data_types"],
                "sample_data": df.head(5).to_dict(orient="records")
            }
            
        except Exception as e:
            # Clean up temp file if it exists
            if temp_file_path.exists():
                temp_file_path.unlink()
            
            # Rollback database transaction
            self.db.rollback()
            
            raise HTTPException(
                status_code=500,
                detail=f"Error processing file: {str(e)}"
            )
    
    def _read_file_to_dataframe(self, file_path: Path, file_extension: str) -> pd.DataFrame:
        """Read file into pandas DataFrame based on extension"""
        try:
            if file_extension in [".xlsx", ".xls"]:
                df = pd.read_excel(file_path)
            elif file_extension == ".csv":
                # Try to detect encoding
                with open(file_path, 'rb') as f:
                    raw_data = f.read()
                    encoding = 'utf-8'
                    try:
                        raw_data.decode('utf-8')
                    except UnicodeDecodeError:
                        encoding = 'latin-1'
                
                df = pd.read_csv(file_path, encoding=encoding)
            else:
                raise ValueError(f"Unsupported file type: {file_extension}")
            
            # Clean column names
            df.columns = [self._clean_column_name(col) for col in df.columns]
            
            return df
            
        except Exception as e:
            raise HTTPException(
                status_code=400,
                detail=f"Error reading file: {str(e)}"
            )
    
    def _clean_column_name(self, col_name: str) -> str:
        """Clean column name for database compatibility"""
        import re
        cleaned = re.sub(r'[^a-zA-Z0-9_]', '_', str(col_name))
        cleaned = re.sub(r'_+', '_', cleaned)
        cleaned = cleaned.strip('_')
        if cleaned and not cleaned[0].isalpha():
            cleaned = 'col_' + cleaned
        return cleaned.lower()
    
    def _generate_table_name(self, filename: str) -> str:
        """Generate unique table name"""
        name_part = Path(filename).stem
        name_part = self._clean_column_name(name_part)
        
        import time
        timestamp = int(time.time())
        
        return f"{name_part}_{timestamp}"
    
    def _analyze_dataframe(self, df: pd.DataFrame) -> Dict[str, Any]:
        """Analyze DataFrame structure and data types"""
        data_types = {}
        
        for col in df.columns:
            series = df[col].dropna()
            
            if len(series) == 0:
                data_types[col] = "TEXT"
                continue
            
            # Check for numeric types
            try:
                pd.to_numeric(series)
                if series.dtype in ['int64', 'int32']:
                    data_types[col] = "INTEGER"
                else:
                    data_types[col] = "REAL"
                continue
            except (ValueError, TypeError):
                pass
            
            # Check for dates
            try:
                pd.to_datetime(series)
                data_types[col] = "DATE"
                continue
            except (ValueError, TypeError):
                pass
            
            # Check for boolean
            if series.dtype == 'bool' or set(series.unique().astype(str).str.lower()) <= {'true', 'false', '1', '0', 'yes', 'no'}:
                data_types[col] = "BOOLEAN"
                continue
            
            # Default to text
            data_types[col] = "TEXT"
        
        return {
            "data_types": data_types,
            "row_count": len(df),
            "column_count": len(df.columns)
        }
    
    def _detect_coordinates(self, df: pd.DataFrame) -> bool:
        """Detect if DataFrame contains coordinate columns"""
        coord_patterns = [
            ['lat', 'lon'], ['latitude', 'longitude'],
            ['x', 'y'], ['easting', 'northing'],
            ['coord_x', 'coord_y'], ['x_coord', 'y_coord']
        ]
        
        columns_lower = [col.lower() for col in df.columns]
        
        for pattern in coord_patterns:
            if all(p in columns_lower for p in pattern):
                return True
        
        return False
    
    def _create_table_in_database(self, df: pd.DataFrame, table_name: str, analysis: Dict[str, Any]):
        """Create table in soil_data_upload schema"""
        engine = create_engine(settings.DATABASE_URL)
        
        # Build CREATE TABLE statement
        columns_sql = []
        for col in df.columns:
            pg_type = self._map_to_postgresql_type(analysis["data_types"][col])
            columns_sql.append(f'"{col}" {pg_type}')
        
        create_table_sql = f"""
        CREATE TABLE IF NOT EXISTS soil_data_upload."{table_name}" (
            id SERIAL PRIMARY KEY,
            {', '.join(columns_sql)}
        )
        """
        
        with engine.connect() as conn:
            conn.execute(text(create_table_sql))
            conn.commit()
    
    def _map_to_postgresql_type(self, data_type: str) -> str:
        """Map Python data types to PostgreSQL types"""
        mapping = {
            "INTEGER": "INTEGER",
            "REAL": "REAL",
            "TEXT": "TEXT",
            "DATE": "DATE",
            "BOOLEAN": "BOOLEAN"
        }
        return mapping.get(data_type, "TEXT")
    
    def _insert_data_to_table(self, df: pd.DataFrame, table_name: str):
        """Insert DataFrame data into PostgreSQL table"""
        engine = create_engine(settings.DATABASE_URL)
        
        # Clean data for insertion
        df_clean = df.copy()
        
        # Replace NaN with None for proper NULL handling
        df_clean = df_clean.where(pd.notnull(df_clean), None)
        
        # Insert data using pandas to_sql
        df_clean.to_sql(
            name=table_name,
            con=engine,
            schema="soil_data_upload",
            if_exists="append",
            index=False,
            method="multi"
        )
    
    def get_table_data(self, table_name: str, limit: int = 100, offset: int = 0) -> Dict[str, Any]:
        """Get data from uploaded table"""
        engine = create_engine(settings.DATABASE_URL)
        
        try:
            # Get total count
            count_sql = f'SELECT COUNT(*) FROM soil_data_upload."{table_name}"'
            
            # Get data with pagination
            data_sql = f'''
            SELECT * FROM soil_data_upload."{table_name}" 
            LIMIT {limit} OFFSET {offset}
            '''
            
            with engine.connect() as conn:
                total_count = conn.execute(text(count_sql)).scalar()
                result = conn.execute(text(data_sql))
                
                columns = result.keys()
                data = [dict(zip(columns, row)) for row in result.fetchall()]
                
                return {
                    "data": data,
                    "total_count": total_count,
                    "columns": list(columns),
                    "limit": limit,
                    "offset": offset
                }
                
        except Exception as e:
            raise HTTPException(
                status_code=404,
                detail=f"Table not found or error accessing data: {str(e)}"
            )
    
    def delete_uploaded_table(self, table_name: str):
        """Delete uploaded table and related records"""
        engine = create_engine(settings.DATABASE_URL)
        
        try:
            # Delete from uploaded_dataset and related columns
            uploaded_dataset = self.db.query(UploadedDataset).filter(
                UploadedDataset.table_name == table_name
            ).first()
            
            if uploaded_dataset:
                self.db.delete(uploaded_dataset)
                
                # Drop the table
                drop_sql = f'DROP TABLE IF EXISTS soil_data_upload."{table_name}"'
                with engine.connect() as conn:
                    conn.execute(text(drop_sql))
                    conn.commit()
                
                self.db.commit()
                return {"message": f"Table {table_name} deleted successfully"}
            else:
                raise HTTPException(
                    status_code=404,
                    detail="Table not found in uploaded datasets"
                )
                
        except Exception as e:
            self.db.rollback()
            raise HTTPException(
                status_code=500,
                detail=f"Error deleting table: {str(e)}"
            ) 