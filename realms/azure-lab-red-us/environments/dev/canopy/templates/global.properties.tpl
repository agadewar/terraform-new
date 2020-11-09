realm=${realm}
environment=${environment}

config_folder=/opt/canopy/config

canopy.auth0.service.url=http://canopy-auth0-service/
canopy.customer.service.url=dummy
canopy.device.service.url=http://canopy-device-service/
canopy.fs.service.url=dummy
canopy.hierarchy.service.url=http://canopy-hierarchy-service/
canopy.inventory.service.url=dummy
canopy.leafbroker.service.url=http://eventpipeline-leaf-broker/
canopy.location.service.url=http://canopy-location-service/
canopy.marketplace.service.url=http://canopy-marketplace-service/
canopy.mdm.service.url=dummy
canopy.notification.service.url=http://canopy-notification-service/
canopy.rm.service.url=dummy
canopy.security.service.url=http://canopy-user-service/
canopy.setting.service.url=http://canopy-setting-service/
canopy.settings.service.url=http://canopy-settings-service/
canopy.user.service.url=http://canopy-user-service/
eventpipeline.service.url=http://eventpipeline-service

canopy.portal.url=dummy

email.enabled = false
email.fromAddress=steve.ardis@banyanhills.com

spring.datasource.driver-class-name=com.mysql.jdbc.Driver
spring.datasource.url=jdbc:mysql://sapience-mysql-$${realm}-$${environment}.privatelink.mysql.database.azure.com:$${database.port:3306}/$${database.name}?verifyServerCertificate=false&useSSL=true
spring.datasource.username=$${CANOPY_DATABASE_USERNAME}@sapience-mysql-$${realm}-$${environment}.mysql.database.azure.com
spring.datasource.password=$${CANOPY_DATABASE_PASSWORD}
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQLDialect

flyway.enabled=true

amqp.url=amqps://sapience-$${realm}-$${environment}.servicebus.windows.net?amqp.idleTimeout=120000&amqp.traceFrames=true
amqp.username=RootManageSharedAccessKey
amqp.password=$${CANOPY_AMQP_PASSWORD}

kafka.ssl.endpoint.identification.algorithm=https
kafka.sasl.mechanism=PLAIN
kafka.request.timeout.ms=20000
kafka.bootstrap.servers=${kafka_bootstrap_servers}
kafka.retry.backoff.ms=500
kafka.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="$${KAFKA_USERNAME}" password="$${KAFKA_PASSWORD}";
kafka.security.protocol=SASL_SSL

canopy.security.service.auhtenticationTokenName=canopySecurityToken
canopy.security.service.auhtenticationUser=canopySecurityUser

#Disable discovery
spring.cloud.discovery.enabled = false

#Disable cloud config and config discovery
spring.cloud.config.discovery.enabled = false
spring.cloud.config.enabled = false
