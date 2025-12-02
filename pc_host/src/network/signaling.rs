// use serde::{Deserialize, Serialize};

// #[derive(Debug, Serialize, Deserialize)]
// #[serde(tag = "type", content = "data")]

// pub enum SignalMessage {
//     Join { room:String, name:Option<String> },
//     Leave { room:String },
//     Offer { sdp:String , to: Option<String>},
//     Answer { sdp:String , to: Option<String>},
//     Candidate{ candidate:String, to: Option<String> },
//     Broadcast { text:String  },
//     Ping,
//     Pong,

//     Custom { event:String, payload:serde_json::Value },
// }