use create::command::Command;
use enigo::*;

pub fn execute(cmd: Command){
    let mut enigo = Enigo::new();

    match cmd.action.as_str() {
        "keyboard" => {
            if let Some(key) = cmd.key {
                enigo.key_sequence(&key);
            }
        }

        "mouse_move" => {
            let dx = cmd.dx.unwrap_or(0);
            let dy = cmd.dy.unwrap_or(0);
            enigo.mouse_move_relative(dx, dy);
        }

        _=> println!("Unknown command action: {}", cmd.action)
    }
}