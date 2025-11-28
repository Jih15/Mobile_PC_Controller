use tokio::net::TcpListener;
use tokio_tungstenite::accept_async;
use futures_util::{StreamExt, SinkExt};

use crate::input::controller_event::ControllerEvent;
use crate::input::vigem_mapper::map_event_to_vigem;