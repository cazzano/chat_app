from flask import Blueprint, request, jsonify, g
import sqlite3
import os
import hashlib
from functools import wraps

# Create Blueprint
user_bp = Blueprint('user', __name__)

# Database configuration
DATABASE = 'users.db'

def get_db():
    """Get database connection"""
    db = sqlite3.connect(DATABASE)
    db.row_factory = sqlite3.Row
    return db

def init_db():
    """Initialize database with users table"""
    if not os.path.exists(DATABASE):
        with sqlite3.connect(DATABASE) as conn:
            conn.execute('''
                CREATE TABLE IF NOT EXISTS users (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    user_id TEXT UNIQUE NOT NULL,
                    username TEXT UNIQUE NOT NULL,
                    password TEXT NOT NULL,
                    secret_key TEXT NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            ''')
            conn.commit()
        print(f"Database '{DATABASE}' created successfully!")

def generate_user_id():
    """Generate next user_id in format U01, U02, etc."""
    with get_db() as conn:
        cursor = conn.execute('SELECT COUNT(*) as count FROM users')
        count = cursor.fetchone()['count']
        next_id = count + 1
        return f"U{next_id:02d}"

def hash_password(password):
    """Hash password using SHA256"""
    return hashlib.sha256(password.encode()).hexdigest()

def validate_headers():
    """Validate required headers are present"""
    required_headers = ['username', 'password', 'secret-key']
    missing_headers = []
    
    for header in required_headers:
        if not request.headers.get(header):
            missing_headers.append(header)
    
    return missing_headers

@user_bp.route('/register', methods=['POST'])
def register_user():
    """Register a new user via headers"""
    try:
        # Initialize database if it doesn't exist
        init_db()
        
        # Validate headers
        missing_headers = validate_headers()
        if missing_headers:
            return jsonify({
                'error': 'Missing required headers',
                'missing_headers': missing_headers,
                'required_headers': ['username', 'password', 'secret-key']
            }), 400
        
        # Get data from headers
        username = request.headers.get('username')
        password = request.headers.get('password')
        secret_key = request.headers.get('secret-key')
        
        # Validate data
        if not all([username.strip(), password.strip(), secret_key.strip()]):
            return jsonify({
                'error': 'Headers cannot be empty'
            }), 400
        
        # Check if username already exists
        with get_db() as conn:
            cursor = conn.execute('SELECT username FROM users WHERE username = ?', (username,))
            existing_user = cursor.fetchone()
            
            if existing_user:
                return jsonify({
                    'error': 'Username already exists',
                    'message': f'Username "{username}" is already taken. Please choose a different username.'
                }), 409
        
        # Generate user_id
        user_id = generate_user_id()
        
        # Hash password
        hashed_password = hash_password(password)
        
        # Insert user into database
        with get_db() as conn:
            try:
                conn.execute('''
                    INSERT INTO users (user_id, username, password, secret_key)
                    VALUES (?, ?, ?, ?)
                ''', (user_id, username, hashed_password, secret_key))
                conn.commit()
                
                return jsonify({
                    'message': 'User registered successfully',
                    'user_id': user_id,
                    'username': username,
                    'status': 'success'
                }), 201
                
            except sqlite3.IntegrityError as e:
                if 'user_id' in str(e):
                    return jsonify({
                        'error': 'User ID already exists',
                        'message': 'Please try again'
                    }), 409
                elif 'username' in str(e):
                    return jsonify({
                        'error': 'Username already exists',
                        'message': f'Username "{username}" is already taken. Please choose a different username.'
                    }), 409
                else:
                    return jsonify({
                        'error': 'Database constraint error',
                        'message': str(e)
                    }), 409
    
    except Exception as e:
        return jsonify({
            'error': 'Internal server error',
            'message': str(e)
        }), 500

@user_bp.route('/users', methods=['GET'])
def get_all_users():
    """Get all registered users (for testing purposes)"""
    try:
        with get_db() as conn:
            cursor = conn.execute('''
                SELECT user_id, username, created_at 
                FROM users 
                ORDER BY id ASC
            ''')
            users = [dict(row) for row in cursor.fetchall()]
            
            return jsonify({
                'users': users,
                'total_count': len(users)
            }), 200
    
    except Exception as e:
        return jsonify({
            'error': 'Internal server error',
            'message': str(e)
        }), 500

@user_bp.route('/users/<user_id>', methods=['GET'])
def get_user_by_id(user_id):
    """Get specific user by user_id"""
    try:
        with get_db() as conn:
            cursor = conn.execute('''
                SELECT user_id, username, created_at 
                FROM users 
                WHERE user_id = ?
            ''', (user_id,))
            user = cursor.fetchone()
            
            if user:
                return jsonify({
                    'user': dict(user)
                }), 200
            else:
                return jsonify({
                    'error': 'User not found'
                }), 404
    
    except Exception as e:
        return jsonify({
            'error': 'Internal server error',
            'message': str(e)
        }), 500

# Initialize database when blueprint is imported
if __name__ != '__main__':
    init_db()
