
#[derive(Clone, Copy, Debug)]
pub enum ResponseCurve {
    Linear, 
    Exponential(f32),
}

#[derive(Debug)]
pub struct AxisState {
    pub raw: f32,
    pub filtered: f32,
}
