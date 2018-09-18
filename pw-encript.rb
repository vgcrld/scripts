ALPHABET = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 '
ENCODING = ' vB0w6blRQVtuHOihIoCMNx2rUqAGmncz8sgZjd457Y1D3fk9SXTLWJpKeFyEPa'

def encode(text)
  text.tr(ALPHABET, ENCODING)
end

def decode(text)
  text.tr(ENCODING, ALPHABET)
end

until( (data = gets.chomp).empty? )
  puts data
  encoded = encode(data)
  puts encoded
end

