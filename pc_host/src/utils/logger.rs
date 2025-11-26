use env_logger::Env;

pub fn init_logger() {
    let env = Env::default().filter_or("RUST_LOG", "info");
    env_logger::init_from_env(env);
}
