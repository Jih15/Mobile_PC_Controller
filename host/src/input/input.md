## controller_event.rs
### Atribut
| Atribut        | Fungsi                     |
| -------------- | -------------------------- |
| `#[derive(Debug)]`      | Event bisa dicetak dengan {:?}, berguna untuk log dan debugging       | 
| ```#[derive(Deserialize)]``` | Kompilator menulis otomatis kode pembaca JSON untuk enum ini |
| ```#[serde(tag = "type")]``` | Jenis event dibaca dari field "type" di dalam JSON itu sendiri  | 

