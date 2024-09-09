const express = require('express');
const mysql = require('mysql');

const app = express();
app.use(express.json());

const db = mysql.createConnection({
  host: '<rds-endpoint>',
  user: 'admin',
  password: 'password123',
  database: 'user_db'
});

db.connect((err) => {
  if (err) {
    throw err;
  }
  console.log('MySQL Bağlantısı başarılı');
});

app.post('/login', (req, res) => {
  const { fname, lname, email } = req.body;
  
  const query = 'INSERT INTO users (fname, lname, email) VALUES (?, ?, ?)';
  db.query(query, [fname, lname, email], (err, result) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }
    res.json({ message: 'Kullanıcı başarıyla kaydedildi' });
  });
});

app.listen(3000, () => {
  console.log('Backend server çalışıyor');
});
