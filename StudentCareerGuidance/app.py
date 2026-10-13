# app.py
from flask import Flask, render_template, request, redirect, url_for, session
import sqlite3

app = Flask(__name__)
app.secret_key = "super_secret_key_for_student_system"

# Database initialize karne ka function
def init_db():
    conn = sqlite3.connect("database.db")
    cursor = conn.cursor()
    
    # Users (Students) Table
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fullname TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL
        )
    ''')
    
    # Careers Table
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS careers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            keywords TEXT NOT NULL,
            category TEXT NOT NULL
        )
    ''')
    
    # Kuch dummy data careers table mein add karna (agar table khali ho)
    cursor.execute("SELECT COUNT(*) FROM careers")
    if cursor.fetchone()[0] == 0:
        dummy_careers = [
            ("AI Engineer", "python, ai, machine learning, technology", "Technology"),
            ("Web Developer", "javascript, html, css, design, programming", "Technology"),
            ("Data Analyst", "python, sql, business, analytics", "Business & Tech"),
            ("UI/UX Designer", "design, figma, web, creativity", "Creative Arts"),
            ("Digital Marketer", "business, marketing, social media, ads", "Business")
        ]
        cursor.executemany("INSERT INTO careers (name, keywords, category) VALUES (?, ?, ?)", dummy_careers)
        conn.commit()
        
    conn.close()

# App shuru hone par DB banao
init_db()

# --- ROUTES ---

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        fullname = request.form['fullname']
        email = request.form['email']
        password = request.form['password']
        
        try:
            conn = sqlite3.connect("database.db")
            cursor = conn.cursor()
            cursor.execute("INSERT INTO users (fullname, email, password) VALUES (?, ?, ?)", (fullname, email, password))
            conn.commit()
            conn.close()
            return redirect(url_for('login'))
        except sqlite3.IntegrityError:
            return "Email already exists! Go back and try another."
            
    return render_template('register.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']
        
        conn = sqlite3.connect("database.db")
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM users WHERE email = ? AND password = ?", (email, password))
        user = cursor.fetchone()
        conn.close()
        
        if user:
            session['user_id'] = user[0]
            session['username'] = user[1]
            return redirect(url_for('dashboard'))
        else:
            return "Invalid Credentials! Please try again."
            
    return render_template('login.html')

@app.route('/dashboard')
def dashboard():
    if 'user_id' not in session:
        return redirect(url_for('login'))
    return render_template('dashboard.html', username=session['username'])

@app.route('/recommend', methods=['POST'])
def recommend():
    if 'user_id' not in session:
        return redirect(url_for('login'))
        
    skills = request.form['skills'].lower()
    interests = request.form['interests'].lower()
    user_input = skills + " " + interests
    
    conn = sqlite3.connect("database.db")
    cursor = conn.cursor()
    cursor.execute("SELECT name, keywords FROM careers")
    all_careers = cursor.fetchall()
    conn.close()
    
    recommendations = []
    
    # Simple Matching Logic: Agar user ke skills/interests career ke keywords se match karein
    for career_name, keywords in all_careers:
        keyword_list = [k.strip() for k in keywords.split(',')]
        for word in keyword_list:
            if word in user_input and career_name not in recommendations:
                recommendations.append(career_name)
                
    return render_template('recommendations.html', recommendations=recommendations)

@app.route('/careers')
def careers():
    conn = sqlite3.connect("database.db")
    cursor = conn.cursor()
    cursor.execute("SELECT id, name, keywords, category FROM careers")
    careers_list = cursor.fetchall()
    conn.close()
    return render_template('careers.html', careers=careers_list)

@app.route('/students')
def students():
    conn = sqlite3.connect("database.db")
    cursor = conn.cursor()
    cursor.execute("SELECT id, fullname, email FROM users")
    students_list = cursor.fetchall()
    conn.close()
    return render_template('students.html', students=students_list)

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('home'))

if __name__ == '__main__':
    app.run(debug=True)