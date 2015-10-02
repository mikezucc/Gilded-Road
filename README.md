# Gilded-Road
Dante's Network Layer

# ABOUT
I am creating an application layer network that will allow individual nodes to act as both hosts and clients at the same time.

A directory of live domains will be maintained at first by an Internet server, but then I will move this to a tarball that will be shared amongst the nodes, relegating some super nodes in charge of keeping master copies based on uptime and my own judgement.

# Nodes
A Node will consist of a renderer and a "node". The renderer will just render HTML or whatever markup. The nodes will be a hybrid of client and server. The client can select from a list of initial domains described in the directory, and then once they choose a domain, traverse the content within that domain. This is similar to a website -> webpage relationship. There will be no DNS resolver for this as of now. Each node is responsbile for maintaining their own domain.

