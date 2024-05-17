import nslsii
from functools import partial
#import ucal
#ucal.STATION_NAME = "sst_sim"
#from ucal.startup import *
import msgpack
import msgpack_numpy as mpn
from bluesky_kafka import Publisher as kafkaPublisher
from bluesky_queueserver import is_re_worker_active
from sst_funcs.configuration import load_and_configure_everything

load_and_configure_everything()

nslsii.configure_base(get_ipython().user_ns, "test", publish_documents_with_kafka=False, bec=False)

if not is_re_worker_active():
    kafka_publisher = kafkaPublisher(
        topic="mad.bluesky.runengine.documents",
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

    token = RE.subscribe(kafka_publisher)
    print(f"kafka token {token}")


RE(psh10.open())
RE(psh7.open())
manipz.velocity.set(100)
RE(mv(manipz, 464))
manipz.velocity.set(1)
