-- Utility functions
function string:split(d, p)
	local t, ll
	t = {}
	ll = 0
	if(#p == 1) then return {p} end
	while true do
		-- Find the next delimiter
		l = string.find(p,d,ll,true)
		-- Found one, save it
		if l ~= nul then
			table.insert(t, string.sub(p, ll, l-1))
			ll = l + 1
		-- Save whatever's left
		else
			table.insert(t, string.sub(p, ll))
			break
		end
	end
	return t
end
