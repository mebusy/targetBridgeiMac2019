Hardware for TargetBridge
=========================

Macs
----

- Sender: Apple Silicon Mac. Intel Macs will NOT work.
- Receiver: Intel or Apple Silicon Mac with a display.
- Both Macs need to support Thunderbolt Bridge (e.g. iMacs >= late 2014)

Typical setups:
- Modern MacBook --TB--> Old iMac (or MacBook or ...)
- Modern Mac mini --TB--> Modern iMac (or MacBook or ...)

Many users will use this to reuse the excellent 5K (4.5K, 4K) display of their iMac.

Tips:
- Intel 27" 5K iMacs have excellent displays and are relatively inexpensive on the used market.
- 2017–2019 models are already quite good, and models configured with a "Fusion Drive" include a connector for a replaceable Apple PCIe blade SSD.
- The 2020 model does not have a replaceable SSD, but it is the last and most modern Intel iMac.
- All Intel 27" iMacs have standard, easily replaceable RAM modules.
- All Intel Macs are a dying breed, which is why you can get them so cheaply. Linux also works well on them, so you can repurpose them for other uses later.
- USB-C style thunderbolt ports usually provide 15W power output.
  Not much, but maybe enough to trickle-charge a modern Macbook with little load.


Cables
------

Here is a list of cables tested by developers or users of this project (provided without any warranty):

- OWC 0.8m Thunderbolt 5 Cable, Type OWCCBLTB5C0.8M, EAN 810159621748
- OWC 1.0m Thunderbolt 5 Cable, Type OWCCBLTB5C1.0M, EAN 810159628105

Notes:
- If you want to buy future-proof cables, go for Thunderbolt 5 (TB5).
- If you want a more affordable option, Thunderbolt 3 (TB3) will also usually work (using USB-C-style connectors).
- Thunderbolt 3, 4, and 5 cables are backward and forward compatible. Slowest
  part (sender, receiver, cable) will determine the speed.


Adapters
--------

When older Macs are involved, they might only have Thunderbolt 2 ports with
Mini-DisplayPort-style connectors. If you want to connect a newer Mac to one of
these, you will need an adapter:

- Apple Thunderbolt 3 (USB-C) to Thunderbolt 2 Adapter

Note: Generic USB C to Mini DisplayPort adapters will not work. They lack the required circuitry to pass through Thunderbolt data. You must use an adapter that explicitly supports Thunderbolt, not just DisplayPort.
