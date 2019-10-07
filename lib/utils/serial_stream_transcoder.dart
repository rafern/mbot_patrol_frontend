import 'package:buffer/buffer.dart';

import 'dart:typed_data';
import 'dart:async';

enum SerialPacketType {
  Unknown, // This should never occur
  Frame,   // 0
  Event,   // 1
  Command, // 2
  Face,    // 3
}

// This class decodes data coming from a serial stream or encodes data into a
// serial stream. The encoding is simple and tries to emulate packets:
// TSSSS[data]
// Where:
// T is a single byte representing the type of data being transferred. Can be:
// - 0: JPEG encoded camera frame
// - 1: An event; E.g. alarm was turned on
// - 2: A command; E.g. turn alarm on
// SSSS are 4 bytes representing a little endian encoded integer representing
// the size of the packet
// [data] is the data being transferred
class SerialStreamTranscoder {
  StreamSink<Uint8List> _outputStream;
  Function(SerialPacketType, Uint8List) _onData;
  Function _onDone;
  BytesBuffer _buffer = BytesBuffer();
  SerialPacketType _expectedType;
  int _expectedSize = 0;

  void _decodeInput(Uint8List data) {
    // Append data to current buffer
    _buffer.add(data, copy: true);

    if(_expectedSize == 0) {
      // If no expected data, then wait for a packet header
      if(_buffer.length >= 5) {
        Uint8List bytes = _buffer.toBytes();

        // Decode packet type
        switch(bytes[0]) {
          case 0:
            _expectedType = SerialPacketType.Frame;
            break;
          case 1:
            _expectedType = SerialPacketType.Event;
            break;
          case 2:
            _expectedType = SerialPacketType.Command;
            break;
          case 3:
            _expectedType = SerialPacketType.Face;
            break;
          default:
            _expectedType = SerialPacketType.Unknown;
        }

        // Decode little endian packet size
        _expectedSize = bytes[4] + (bytes[3] << 8) + (bytes[2] << 16) + (bytes[1] << 24);
      }
    }
    else {
      // Wait for entire packet to be received if data is expected
      if(_buffer.length >= 5 + _expectedSize) {
        Uint8List bytes = _buffer.toBytes();

        _onData(_expectedType, bytes.sublist(5, 5 + _expectedSize));

        _buffer = BytesBuffer();
        _buffer.add(bytes.sublist(5 + _expectedSize));

        _expectedSize = 0;
        _expectedType = null;
      }
    }
  }

  SerialStreamTranscoder(Stream<Uint8List> _inputStream, this._outputStream, this._onData, this._onDone) {
    _inputStream.listen(_decodeInput).onDone(_onDone);
  }

  void write(SerialPacketType type, Uint8List data) {
    // Generate header
    // Encode packet type
    Uint8List header = Uint8List(5);
    switch(type) {
      case SerialPacketType.Frame:
        header[0] = 0;
        break;
      case SerialPacketType.Event:
        header[0] = 1;
        break;
      case SerialPacketType.Command:
        header[0] = 2;
        break;
      case SerialPacketType.Face:
        header[0] = 3;
        break;
      default:
        throw ArgumentError('Unknown packet type: $type');
    }

    const int maxBytes = 2147483647;
    int byteCount = data.lengthInBytes;
    if(byteCount > maxBytes)
      throw RangeError('Packet too big: $byteCount > $maxBytes bytes');

    // Encode packet size as a 32-bit little endian integer
    header[1] = (byteCount >> 24) & 0xFF;
    header[2] = (byteCount >> 16) & 0xFF;
    header[3] = (byteCount >> 8 ) & 0xFF;
    header[4] =  byteCount        & 0xFF;

    // Send header and data
    _outputStream.add(header);
    _outputStream.add(data);
  }
}
