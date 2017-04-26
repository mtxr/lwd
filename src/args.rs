use clap::{Arg, App, SubCommand};

pub fn prepare<'a>() -> App<'a, 'a> {
    return App::new("Last working directory")
      .version("1.0")
      .author("Matheus T. <me@mteixeira.me>")
      .about("Last working directory")
      .subcommand(
        SubCommand::with_name("add")
          .about("Add path to lwd")
          .arg(
            Arg::with_name("path")
              .help("the path to add")
              .index(1)
              .required(true)
          )
      )
      .subcommand(
        SubCommand::with_name("search")
          .about("Searchs last working paths")
          .arg(
            Arg::with_name("term")
              .help("the term to search")
              .index(1)
              .required(true)
          )
      );
}

