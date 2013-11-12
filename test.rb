@expl_trans = 255
while @expl_trans > 0
	puts ((@expl_trans << 24) + 0x00ffffff).to_s(16)
	#puts @expl_trans.to_s(16)
	@expl_trans -= 1
end


# @factor = 0 << 24
# puts @factor.to_s(16)
# for i in 0x1..0xff
# 	@factor = (i << 24) + 0x00ffffff
# 	puts @factor.to_s(16)
# end