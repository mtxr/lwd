extern crate clap;

#[macro_use]
mod args;

#[macro_use]
mod process;

fn main() {
  let matches = args::prepare().get_matches();
  
  match matches.subcommand_name() {
    Some("add") => process::add("a"),
    Some("search") => process::search("ab"),
    _        => process::lwd(),
  }
}
