const {Client} = require('pg')

const client = new Client({
    host: "localhost",
    user: "postgres",
    port: 5432,
    password: "postgres1234",
    database: "qrApp"
})

module.exports = client