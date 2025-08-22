#!/bin/bash

# Development startup script for SIS API

set -e

echo "🚀 Starting SIS API Development Environment"

# Check if .env exists
if [ ! -f .env ]; then
    echo "📋 Creating .env from template..."
    cp .env.example .env
    echo "⚠️  Please edit .env with your database credentials before continuing"
    exit 1
fi

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "🐍 Creating Python virtual environment..."
    python -m venv venv
fi

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo "📦 Installing dependencies..."
pip install -r requirements.txt

# Create uploads directory
echo "📁 Creating uploads directory..."
mkdir -p uploads

# Check if database is accessible
echo "🗄️  Checking database connection..."
python -c "
import psycopg2
import os
from dotenv import load_dotenv

load_dotenv()

try:
    conn = psycopg2.connect(
        host=os.getenv('DB_HOST', 'localhost'),
        port=os.getenv('DB_PORT', '5432'),
        database=os.getenv('DB_NAME', 'sis_database'),
        user=os.getenv('DB_USER', 'sis'),
        password=os.getenv('DB_PASSWORD', 'password')
    )
    conn.close()
    print('✅ Database connection successful')
except Exception as e:
    print(f'❌ Database connection failed: {e}')
    print('Please ensure PostgreSQL is running and credentials are correct')
    exit(1)
"

if [ $? -ne 0 ]; then
    exit 1
fi

echo "🌟 Starting FastAPI development server..."
echo "📖 API Documentation will be available at: http://localhost:8000/api/v1/docs"
echo "🔗 API Base URL: http://localhost:8000"
echo ""

# Start the development server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000 