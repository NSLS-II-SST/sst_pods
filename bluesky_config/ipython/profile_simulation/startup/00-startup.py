import nslsii
from functools import partial
import ucal
ucal.STATION_NAME = "sst_sim"
from ucal.startup import *
from bluesky.callbacks.best_effort import BestEffortCallback
from bluesky.callbacks import LiveTable
import msgpack
import msgpack_numpy as mpn
from bluesky_kafka import Publisher as kafkaPublisher

nslsii.configure_base(get_ipython().user_ns, "test", publish_documents_with_kafka=False)

kafka_publisher = kafkaPublisher(
    topic="mad.bluesky.documents",
    bootstrap_servers="127.0.0.1:29092",
    key="kafka-unit-test-key",
    # work with a single broker
    producer_config={
        "acks": 1,
        "enable.idempotence": False,
        "request.timeout.ms": 5000,
    },
    serializer=partial(msgpack.dumps, default=mpn.encode),
)


ucal_sd.baseline.append(eslit)
#bec = BestEffortCallback()

#RE.subscribe(bec)
#RE.subscribe(db.insert)
RE.subscribe(kafka_publisher)

RE._call_returns_result = False
#LiveTable._FMT_MAP["number"] = "g"


# Setup
RE(psh10.open())
RE(psh7.open())
manipz.velocity.set(100)
RE(mv(manipz, 464))
manipz.velocity.set(1)
