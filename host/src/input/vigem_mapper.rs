use std::sync::Arc;

use vigem_client::{Client, Xbox360Wired};

struct VigemContext {
    controller: XBox360Wired<Arc<Client>>,
}