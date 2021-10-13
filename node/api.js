import Lettura from './lettura.js';
const client = require('./connection.js');
const express = require('express');
const bp = require('body-parser');



const app = express();

// dobbiamo usare questi metodi per poter setacciare i dati
app.use(bp.json())
app.use(bp.urlencoded({ extended: true }))


// ci mettiamo in ascolto nella porta 3000
app.listen(3000, ()=>{
    console.log("Sever in ascolto sulla porta 3000");
})

client.connect();

app.get('/persona', (req, res)=>{
    client.query(`Select * from persona`, (err, result)=>{
        if(!err){
            res.send(result.rows);
        }
    });
    client.end;
})

app.post('/lettura', (req,res) => {
    const datiRicevuti = req.body;
    let lettura = new Lettura(req.body.id_device,req.body.orario);

    // fare un controllo 
    let insertQuery =  `insert into lettura(id_persona,orario_entrata,orario_uscita,quantita) 
    values(${lettura.id_device},'${lettura.orario}','${lettura.orario_uscita}','${lettura.quantita}')`

    client.query(insertQuery, (err,result)=>{
        if(!err){
            res.send(result.rows);
        }else{
            console.log(err.message);
        }
    });
    client.end;
})



app.post('/',(req,res) => {
    const {id_device} = req.body;

    // validazione semplice
    if(!id_device)
        return res.status(400).json({msg: "Errore, non trovo id device"});
    // validazione se id_device esiste
    //id_device.findOne({id_device}).then(id_device) => {

    //}
})
// app.delete('/')