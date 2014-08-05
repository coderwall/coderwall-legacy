Handlebars.registerHelper "each_network", (block)->
  block(network) for network in Coderwall.AllNetworksView.networks when network[0].toUpperCase() == @[0]