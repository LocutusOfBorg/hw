use log::*;

use crate::core::{server::HwServer, types::ClientId};
use hedgewars_network_protocol::messages::HwProtocolMessage;

pub fn handle(_server: &mut HwServer, _client_id: ClientId, message: HwProtocolMessage) {
    match message {
        _ => warn!("Unknown command"),
    }
}
