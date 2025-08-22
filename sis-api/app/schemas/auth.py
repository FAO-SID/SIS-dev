from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import date


class Token(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class TokenData(BaseModel):
    username: Optional[str] = None


class UserLogin(BaseModel):
    individual_id: str
    password: str


class UserCreate(BaseModel):
    individual_id: str
    email: EmailStr
    password: str
    organisation_id: Optional[str] = None
    is_admin: bool = False


class UserResponse(BaseModel):
    individual_id: str
    organisation_id: Optional[str] = None
    created_at: Optional[date] = None
    last_login: Optional[date] = None
    is_active: bool = True
    is_admin: bool = False

    class Config:
        from_attributes = True


class UserUpdate(BaseModel):
    organisation_id: Optional[str] = None
    is_active: Optional[bool] = None
    is_admin: Optional[bool] = None


class PasswordChange(BaseModel):
    current_password: str
    new_password: str


class RefreshToken(BaseModel):
    refresh_token: str 