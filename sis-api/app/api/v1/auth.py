from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from app.api.deps import get_db, get_current_user
from app.core.security import (
    verify_password, 
    get_password_hash, 
    create_token_pair,
    verify_token,
    TOKEN_TYPE_REFRESH
)
from app.models.api_models import User
from app.models.soil_data_models import Individual
from app.schemas.auth import (
    Token, 
    UserLogin, 
    UserCreate, 
    UserResponse, 
    PasswordChange,
    RefreshToken
)

router = APIRouter()


@router.post("/login", response_model=Token)
def login_for_access_token(
    user_credentials: UserLogin,
    db: Session = Depends(get_db)
):
    """
    Login endpoint to get access token
    """
    user = authenticate_user(db, user_credentials.individual_id, user_credentials.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Update last login
    user.last_login = datetime.utcnow().date()
    db.commit()
    
    # Create token pair
    tokens = create_token_pair(user.individual_id)
    return tokens


@router.post("/refresh", response_model=Token)
def refresh_access_token(
    refresh_data: RefreshToken,
    db: Session = Depends(get_db)
):
    """
    Refresh access token using refresh token
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        user_id = verify_token(refresh_data.refresh_token, TOKEN_TYPE_REFRESH)
        if user_id is None:
            raise credentials_exception
    except Exception:
        raise credentials_exception
    
    user = db.query(User).filter(User.individual_id == user_id).first()
    if user is None or not user.is_active:
        raise credentials_exception
    
    # Create new token pair
    tokens = create_token_pair(user.individual_id)
    return tokens


@router.post("/logout")
def logout(current_user: User = Depends(get_current_user)):
    """
    Logout endpoint (token invalidation would be handled client-side or with Redis)
    """
    return {"message": "Successfully logged out"}


@router.post("/register", response_model=UserResponse)
def register_user(
    user_data: UserCreate,
    db: Session = Depends(get_db)
):
    """
    Register a new user
    """
    # Check if user already exists in api.user table
    existing_user = db.query(User).filter(User.individual_id == user_data.individual_id).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User already registered"
        )
    
    # Check if individual exists in soil_data.individual table
    individual = db.query(Individual).filter(Individual.individual_id == user_data.individual_id).first()
    if not individual:
        # Create individual first
        individual = Individual(
            individual_id=user_data.individual_id,
            email=user_data.email
        )
        db.add(individual)
        db.flush()
    
    # Create user in api.user table
    hashed_password = get_password_hash(user_data.password)
    db_user = User(
        individual_id=user_data.individual_id,
        organisation_id=user_data.organisation_id,
        password_hash=hashed_password,
        is_admin=user_data.is_admin,
        created_at=datetime.utcnow().date()
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    
    return db_user


@router.post("/change-password")
def change_password(
    password_data: PasswordChange,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Change user password
    """
    if not verify_password(password_data.current_password, current_user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Incorrect current password"
        )
    
    # Update password
    current_user.password_hash = get_password_hash(password_data.new_password)
    db.commit()
    
    return {"message": "Password changed successfully"}


@router.get("/me", response_model=UserResponse)
def read_users_me(current_user: User = Depends(get_current_user)):
    """
    Get current user information
    """
    return current_user


def authenticate_user(db: Session, individual_id: str, password: str) -> User:
    """
    Authenticate user credentials
    """
    user = db.query(User).filter(User.individual_id == individual_id).first()
    if not user:
        return False
    if not verify_password(password, user.password_hash):
        return False
    return user 