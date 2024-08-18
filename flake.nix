{
  description = "My collection of flake templates";
  outputs = {self}: {
    templates = {
      rust = {
        path = ./rust;
        description = "Rust template, using Naersk and Fenix";
      };

      defaultTemplate = self.templates.rust;
    };
  };
}
