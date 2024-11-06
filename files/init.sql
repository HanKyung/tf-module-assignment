CREATE TABLE IF NOT EXISTS friends (
    id INTEGER AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    role VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    gender VARCHAR(10) NOT NULL,
    img_url VARCHAR(200)
)

