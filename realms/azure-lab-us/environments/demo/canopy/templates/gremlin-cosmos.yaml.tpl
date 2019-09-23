hosts: [ sapience-canopy-hierarchy-${realm}-${environment}.gremlin.cosmos.azure.com ]
port: 443
username: /dbs/canopy/colls/hierarchy
password: ${canopy_hierarchy_cosmos_password}
connectionPool: {
  enableSsl: true
}
#serializer: { className: org.apache.tinkerpop.gremlin.driver.ser.GryoMessageSerializerV1d0, config: { serializeResultToString: false }}
#serializer: { className: org.apache.tinkerpop.gremlin.driver.ser.GryoMessageSerializerV3d0, config: { serializeResultToString: false }}
serializer: { className: org.apache.tinkerpop.gremlin.driver.ser.GraphSONMessageSerializerV1d0, config: { serializeResultToString: true }}
