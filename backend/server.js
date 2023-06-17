const express = require('express');
const mysql = require('mysql2');
const app = express();
const cors = require('cors');

app.use(express.json());
app.use(cors({ origin: 'http://localhost:3000' }));


const db = mysql.createConnection({
    host: 'localhost',
    user: 'toto',
    password: 'toto',
    database: 'testdb'
});

db.connect(function (err) {
    if (err) {
        console.error('An error occurred while connecting to the DB')
        throw err
    }
    console.log('Connected!')
});

app.listen(1993, () => {
    console.log('Server started on port 1993');
});


app.post('/user', (req, res) => {
    let sql = 'INSERT INTO users SET ?';
    let query = db.query(sql, req.body, (err, result) => {
        if (err) {
            res.send(err);
        } else {
            res.send('User added...');
        }
    });
});

// READ
app.get('/user', (req, res) => {
    let sql = 'SELECT * FROM users;';
    let query = db.query(sql, (err, results) => {
        if (err) {
            res.send(err);
        } else {
            res.send(results);
        }
    });
});

// UPDATE
app.put('/user/:id', (req, res) => {
    let sql = `UPDATE users SET ? WHERE id = ?`;
    let query = db.query(sql, [req.body, req.params.id], (err, result) => {
        if (err) {
            res.send(err);
        } else {
            res.send('User updated...');
        }
    });
});

// DELETE
app.delete('/user/:id', (req, res) => {
    let sql = `DELETE FROM users WHERE id = ?`;
    let query = db.query(sql, req.params.id, (err, result) => {
        if (err) {
            res.send(err);
        } else {
            res.send('User deleted...');
        }
    });
});
