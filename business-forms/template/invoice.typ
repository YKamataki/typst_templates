#import "lib.typ": invoice
#invoice(json(sys.inputs.at("data", default: "data/invoice.json")))
