from flask import Flask, render_template, request, redirect, url_for
import mysql.connector

app = Flask(__name__)

# Database config helper function taake har request par naya connection sahi se bane aur close ho
def get_db_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="123456",  # Aapka password
        database="career_guidance"
    )

# ==========================================
# DATABASE SETTINGS & TABLES CREATION (Sirf Startup ke liye)
# ==========================================
try:
    # 1. MySQL Server se connect karein
    db = mysql.connector.connect(
        host="localhost",
        user="root",
        password="123456"
    )
    cursor = db.cursor()

    # 2. Database banana aur select karna
    cursor.execute("CREATE DATABASE IF NOT EXISTS career_guidance")
    cursor.execute("USE career_guidance")

    # 3. Students Table banana
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS students (
            id INT AUTO_INCREMENT PRIMARY KEY,
            fullname VARCHAR(100) NOT NULL,
            email VARCHAR(100) UNIQUE NOT NULL,
            password VARCHAR(100) NOT NULL,
            age INT,
            gpa FLOAT,
            skills TEXT,
            interests TEXT
        )
    """)

    # 4. Careers Table banana
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS careers (
            career_id INT AUTO_INCREMENT PRIMARY KEY,
            career_name VARCHAR(100),
            required_skills TEXT,
            category VARCHAR(100),
            description TEXT
        )
    """)

    # 5. Careers data insertion check
    cursor.execute("SELECT COUNT(*) FROM careers")
    if cursor.fetchone()[0] == 0:
        careers_data = [
            ('Software Engineer', 'Programming,Python', 'IT', 'Develop software applications'),
            ('Data Scientist', 'Python,Statistics', 'IT', 'Analyze data and create insights'),
            ('AI Engineer', 'Python,Machine Learning', 'AI', 'Build AI systems'),
            ('Cyber Security Specialist', 'Networking,Security', 'IT', 'Protect systems from attacks'),
            ('Graphic Designer', 'Design,Creativity', 'Creative', 'Create graphics and designs'),
            ('Business Analyst', 'Communication,Business', 'Management', 'Analyze business requirements')
        ]
        
        insert_query = """
            INSERT INTO careers (career_name, required_skills, category, description) 
            VALUES (%s, %s, %s, %s)
        """
        cursor.executemany(insert_query, careers_data)
        db.commit()
        print(" [INFO] Careers ka data pehli dafa insert kar diya gaya hai.")

    print(" [SUCCESS] Database, Tables aur Data bilkul sahi set ho chuke hain!")
    cursor.close()
    db.close()

except mysql.connector.Error as err:
    print(f" [ERROR] Database mein masla aya hai: {err}")


# ==========================================
# FLASK WEB ROUTES (Aapke Pages)
# ==========================================

@app.route('/')
def home():
    return """
    <div style="text-align: center; margin-top: 50px; font-family: Arial;">
        <h1 style="color: #2c3e50;">Student Career Guidance System</h1>
        <p style="color: #27ae60; font-size: 18px; font-weight: bold;">
            🚀 Aapka Flask Server chal raha hai aur MySQL se tables connect ho chuke hain!
        </p>
        <p style="color: #7f8c8d;">Ab aap apna HTML frontend (templates) iske sath jor sakte hain.</p>
    </div>
    """

# NAYA ROUTE: Is se aap bina locked ke jitne chahein students add kar sakte hain
@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        # Form se data lena (Aapke HTML form ke name attributes se match hona chahiye)
        fullname = request.form.get('fullname')
        email = request.form.get('email')
        password = request.form.get('password')
        age = request.form.get('age')
        gpa = request.form.get('gpa')
        skills = request.form.get('skills')
        interests = request.form.get('interests')

        conn = None
        cursor = None
        try:
            # Connection open kiya
            conn = get_db_connection()
            cursor = conn.cursor()

            # Query chalayi
            query = """
                INSERT INTO students (fullname, email, password, age, gpa, skills, interests)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """
            values = (fullname, email, password, age, gpa, skills, interests)
            cursor.execute(query, values)
            
            # Data save kiya
            conn.commit()
            return "Student Registered Successfully! Ab aap doosra student add kar sakte hain."

        except mysql.connector.Error as err:
            return f"Error aya registration mein: {err}"
        
        finally:
            # Connection lazmi close kiya taake multi-users bina lock ke kaam karein
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    # Agar GET request ho to register.html render karein (agar aapke paas template hai)
    return render_template('register.html') 

if __name__ == '__main__':
    app.run(debug=True)