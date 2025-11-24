use serde::Deserialize;

pub struct Command {
    pub action: String,

    // Keyboard
    pub key: Option<String>,
    pub r#type: Option<String>,

    // Mouse Move
    pub dx: Option<i32>,
    pub dy: Option<i32>,
}