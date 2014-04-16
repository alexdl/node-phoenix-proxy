moment = require 'moment'
ByteBuffer = require 'protobufjs/node_modules/bytebuffer'
ProtoBuf = require("protobufjs")

builder = ProtoBuf.loadProtoFile("#{__dirname}/Phoenix.proto")

DataType = builder.result.DataType


dataConvert =
	INTEGER:
		encode: (v) ->
			b = ByteBuffer.allocate 4
			b.writeInt32 v
			b.toBuffer()
		decode: (b) ->
			b.readInt32BE(0)


	VARCHAR:
		encode: (v) ->
			new Buffer v
		decode: (b) ->
			b.toString()


	BINARY:
		encode: (v) ->
			v
		decode: (b) ->
			b


	DOUBLE:
		encode: (v) ->
			b = ByteBuffer.allocate 8
			b.writeDouble v
			b.toBuffer()
		decode: (b) ->
			x = ByteBuffer.wrap(b).readDouble 0
			x.toString()


	FLOAT:
		encode: (v) ->
			b = ByteBuffer.allocate 4
			b.writeFloat v
			b.toBuffer()
		decode: (b) ->
			x = ByteBuffer.wrap(b).readFloat 0
			x.toString()


	BIGINT:
		encode: (v) ->
			b = ByteBuffer.allocate 8
			b.writeInt64 v
			b.toBuffer()
		decode: (b) ->
			high = b.readInt32BE 4
			low = b.readInt32BE 0
			x = ByteBuffer.Long.fromBits high, low, yes
			x.toString()


	BOOLEAN:
		encode: (v) ->
			new Buffer [if v then 1 else 0]
		decode: (b) ->
			b.readInt8(0) is 1


	TIMESTAMP:
		encode: (v) ->
			b = ByteBuffer.allocate 12
			b.writeInt64 v.valueOf()
			b.writeInt32 0
			b.toBuffer()
		decode: (b) ->
			high = b.readInt32BE 4
			low = b.readInt32BE 0
			x = ByteBuffer.Long.fromBits high, low, yes

			moment.utc(parseInt x).toDate()


	DATE:
		encode: (v) ->
			b = ByteBuffer.allocate 8
			b.writeInt64 v.valueOf()
			b.toBuffer()
		decode: (b) ->
			high = b.readInt32BE 4
			low = b.readInt32BE 0
			x = ByteBuffer.Long.fromBits high, low, yes

			moment.utc(parseInt x).format('YYYY-MM-DD')


	TINYINT:
		encode: (v) ->
			b = ByteBuffer.allocate 1
			b.writeInt8 v
			b.toBuffer()
		decode: (b) ->
			b.readInt8(0)


	SMALLINT:
		encode: (v) ->
			b = ByteBuffer.allocate 2
			b.writeInt16 v
			b.toBuffer()
		decode: (b) ->
			b.readInt16BE(0)


	DECIMAL:
		encode: (v) ->
			b = ByteBuffer.allocate 8
			b.writeDouble v
			b.toBuffer()
		decode: (b) ->
			x = ByteBuffer.wrap(b).readDouble 0
			x.toString()


	TIME:
		encode: (v) ->
			b = ByteBuffer.allocate 8
			b.writeInt64 v.valueOf()
			b.toBuffer()
		decode: (b) ->
			high = b.readInt32BE 4
			low = b.readInt32BE 0
			x = ByteBuffer.Long.fromBits high, low, yes

			moment.utc(parseInt x).format('HH:mm:ss')


	CHAR:
		encode: (v) ->
			new Buffer v
		decode: (b) ->
			b.toString()


	VARBINARY:
		encode: (v) ->
			v
		decode: (b) ->
			b


# reverse enum
dataConvert[DataType[type]] = dataConvert[type] for type in Object.keys dataConvert


module.exports = dataConvert
