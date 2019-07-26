eventpipeline.sources = eventpipeline
eventpipeline.channels = logger eventarchive eventprocessing
eventpipeline.sinks = logger eventarchive eventprocessing

eventpipeline.sources.eventpipeline.type = com.banyanhills.eventpipeline.flume.source.KafkaSource
eventpipeline.sources.eventpipeline.channels = logger eventarchive eventprocessing deviceregistration
eventpipeline.sources.eventpipeline.batchSize = 1000
eventpipeline.sources.eventpipeline.kafka.bootstrap.servers = ${kafka_bootstrap_servers}
eventpipeline.sources.eventpipeline.kafka.consumer.sasl.jaas.config = org.apache.kafka.common.security.plain.PlainLoginModule required username="$${KAFKA_USERNAME}" password="$${KAFKA_PASSWORD}";
eventpipeline.sources.eventpipeline.kafka.consumer.sasl.mechanism = PLAIN
eventpipeline.sources.eventpipeline.kafka.consumer.ssl.endpoint.identification.algorithm = https
eventpipeline.sources.eventpipeline.kafka.consumer.security.protocol = SASL_SSL
eventpipeline.sources.eventpipeline.kafka.topics = canopy-eventpipeline
eventpipeline.sources.eventpipeline.interceptors = sapienceinterceptor
eventpipeline.sources.eventpipeline.interceptors.sapienceinterceptor.type = com.sapience.eventpipeline.flume.interceptor.SapienceEventPipelineInterceptor$Builder

#eventpipeline.sources.eventpipeline.selector.type = multiplexing
#eventpipeline.sources.eventpipeline.selector.header = messageType-statisticType
#eventpipeline.sources.eventpipeline.selector.mapping.statistic-agentInfo = logger deviceregistration eventarchive
#eventpipeline.sources.eventpipeline.selector.default = logger eventarchive

eventpipeline.channels.logger.type = memory
eventpipeline.channels.logger.capacity = 10000
eventpipeline.channels.logger.transactionCapacity = 1000

eventpipeline.sinks.logger.type = logger
eventpipeline.sinks.logger.channel = logger

#eventpipeline.channels.deviceregistration.type = memory
#eventpipeline.channels.deviceregistration.capacity = 10000
#eventpipeline.channels.deviceregistration.transactionCapacity = 1000

#eventpipeline.sinks.deviceregistration.type = logger
#eventpipeline.sinks.deviceregistration.channel = deviceregistration

eventpipeline.channels.eventarchive.type = org.apache.flume.channel.kafka.KafkaChannel
eventpipeline.channels.eventarchive.kafka.bootstrap.servers = ${kafka_bootstrap_servers}
eventpipeline.channels.eventarchive.kafka.consumer.sasl.jaas.config = org.apache.kafka.common.security.plain.PlainLoginModule required username="$${KAFKA_USERNAME}" password="$${KAFKA_PASSWORD}";
eventpipeline.channels.eventarchive.kafka.consumer.sasl.mechanism = PLAIN
eventpipeline.channels.eventarchive.kafka.consumer.ssl.endpoint.identification.algorithm = https
eventpipeline.channels.eventarchive.kafka.consumer.security.protocol = SASL_SSL
eventpipeline.channels.eventarchive.kafka.producer.sasl.jaas.config = org.apache.kafka.common.security.plain.PlainLoginModule required username="$${KAFKA_USERNAME}" password="$${KAFKA_PASSWORD}";
eventpipeline.channels.eventarchive.kafka.producer.sasl.mechanism = PLAIN
eventpipeline.channels.eventarchive.kafka.producer.ssl.endpoint.identification.algorithm = https
eventpipeline.channels.eventarchive.kafka.producer.security.protocol = SASL_SSL
eventpipeline.channels.eventarchive.kafka.topic = eventarchive-channel

eventpipeline.sinks.eventarchive.type = hdfs
eventpipeline.sinks.eventarchive.channel = eventarchive
eventpipeline.sinks.eventarchive.hdfs.path = abfss://sapience-adls@sapiencedatalake${environment}.dfs.core.windows.net/rawdata/avro/tenantId=%%{tenantId}/companyId=%%{companyId}/year=%Y/month=%m/day=%d/hour=%H/minute=%M
eventpipeline.sinks.eventarchive.hdfs.fileType = DataStream
eventpipeline.sinks.eventarchive.hdfs.writeFormat = Text
eventpipeline.sinks.eventarchive.hdfs.filePrefix = EventData
eventpipeline.sinks.eventarchive.hdfs.fileSuffix = .avro
eventpipeline.sinks.eventarchive.hdfs.rollSize = 0
eventpipeline.sinks.eventarchive.hdfs.rollCount = 0
eventpipeline.sinks.eventarchive.serializer = avro_event
eventpipeline.sinks.eventarchive.serializer.compressionCodec = snappy

eventpipeline.channels.eventprocessing.type = org.apache.flume.channel.kafka.KafkaChannel
eventpipeline.channels.eventprocessing.kafka.bootstrap.servers = ${kafka_bootstrap_servers}
eventpipeline.channels.eventprocessing.kafka.consumer.sasl.jaas.config = org.apache.kafka.common.security.plain.PlainLoginModule required username="$${KAFKA_USERNAME}" password="$${KAFKA_PASSWORD}";
eventpipeline.channels.eventprocessing.kafka.consumer.sasl.mechanism = PLAIN
eventpipeline.channels.eventprocessing.kafka.consumer.ssl.endpoint.identification.algorithm = https
eventpipeline.channels.eventprocessing.kafka.consumer.security.protocol = SASL_SSL
eventpipeline.channels.eventprocessing.kafka.producer.sasl.jaas.config = org.apache.kafka.common.security.plain.PlainLoginModule required username="$${KAFKA_USERNAME}" password="$${KAFKA_PASSWORD}";
eventpipeline.channels.eventprocessing.kafka.producer.sasl.mechanism = PLAIN
eventpipeline.channels.eventprocessing.kafka.producer.ssl.endpoint.identification.algorithm = https
eventpipeline.channels.eventprocessing.kafka.producer.security.protocol = SASL_SSL
eventpipeline.channels.eventprocessing.kafka.topic = eventprocessing-channel

eventpipeline.sinks.eventprocessing.type = org.apache.flume.sink.kafka.KafkaSink
eventpipeline.sinks.eventprocessing.channel = eventprocessing
eventpipeline.sinks.eventprocessing.kafka.bootstrap.servers = ${kafka_bootstrap_servers}
eventpipeline.sinks.eventprocessing.kafka.consumer.sasl.jaas.config = org.apache.kafka.common.security.plain.PlainLoginModule required username="$${KAFKA_USERNAME}" password="$${KAFKA_PASSWORD}";
eventpipeline.sinks.eventprocessing.kafka.consumer.sasl.mechanism = PLAIN
eventpipeline.sinks.eventprocessing.kafka.consumer.ssl.endpoint.identification.algorithm = https
eventpipeline.sinks.eventprocessing.kafka.consumer.security.protocol = SASL_SSL
eventpipeline.sinks.eventprocessing.kafka.producer.sasl.jaas.config = org.apache.kafka.common.security.plain.PlainLoginModule required username="$${KAFKA_USERNAME}" password="$${KAFKA_PASSWORD}";
eventpipeline.sinks.eventprocessing.kafka.producer.sasl.mechanism = PLAIN
eventpipeline.sinks.eventprocessing.kafka.producer.ssl.endpoint.identification.algorithm = https
eventpipeline.sinks.eventprocessing.kafka.producer.security.protocol = SASL_SSL
eventpipeline.sinks.eventprocessing.allowTopicOverride = false
eventpipeline.sinks.eventprocessing.kafka.topic = eventprocessing
