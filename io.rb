rd, wr = IO.pipe

# This will be the "parent" because the block will only execute if fork returns other than nil
if fork
  wr.close
  puts "Parent got: <#{rd.read}>"
  rd.close
  Process.wait

# This will run as the
else
  rd.close
  puts "Sending message to parent"
  wr.write "Hi Dad"
  wr.close
end
