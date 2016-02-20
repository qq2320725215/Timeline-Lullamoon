--[[
           DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
                   Version 2, December 2004

Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>

Everyone is permitted to copy and distribute verbatim or modified
copies of this license document, and changing it is allowed as long
as the name is changed.

           DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
  TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

 0. You just DO WHAT THE FUCK YOU WANT TO.

--]]

--[[
	Author: Yoshiko_G
	Special Thanks to: TNBi, DracoRunan, ruzx007878
--]]

script_name = "TimeLine Lullamoon"
script_description = "1.�Կ���OK��ǩ�Զ����Ͽ��ַ�  2.�����и����β���룬���Զ�������ͻ��ʱ�������Ӷ��ѵ��п���OKת����˫��  3.����Ч�ֶ������ÿո���ϵ������ı���Ҳ���Խ������ı������ظ����Ļ"
script_author = "Yoshiko_G"
script_version = "0.49"

tr = aegisub.gettext

util = require'aegisub.util'

UI_conf = {
	--1,1,1,1,"intedit",value,min,max,"hint"
	--1,1,1,1,"label","text"
	--1,1,1,1,"checkbox",true
	--1,1,1,1,"dropdown","value",{items},"hint"
			
	double_dialogs = {
		info = { 0, 0, 3, 1, "label", label = "" },
		{ 0, 1, 1, 1, "label", label = "Ԥ��:" },
		{ 1, 1, 1, 1, "intedit", name = "timeadv", hint = "ÿ����Ԥ����ʾ��ʱ�䣬��λΪ����", value = 1000, min = 1, max = 20000 },
		{ 2, 1, 1, 1, "label", label = "ms" },
		{ 0, 2, 1, 1, "label", label = "�Ӻ�:" },
		{ 1, 2, 1, 1, "intedit", name = "timepass", value = 1000, min = 1, max = 20000 },
		{ 2, 2, 1, 1, "label", label = "ms" },
		{ 0, 3, 2, 1, "checkbox", name = "fn1", value = true, label = "�Զ�����ʱ�����ͻ" }
	},
	double_buttons = {'Parse!','Cancel'},	
	double_commands = {
		function(subs,sel,config) kara_parse_double(subs, sel, config) end,
		function(subs,sel,config) aegisub.cancel() end
	},
	
	swift_dialogs = {
		info = { 0, 0, 1, 1, "label", label = "��ѡ���ܣ�\nCreate������ʵ����Ļ��������Ч�ֶ����ɰ����ڷָ���ı���\nParse��������Ч�ֶε����ڷָ��ı��޸���Ļ���ݡ�\nClean�������Ч�ֶΡ�"  }
	},
	swift_buttons = {'Create','Parse','Clean','Cancel'},
	swift_commands = {
		function(subs,sel,config) kara_swift(subs, sel, 0) end,
		function(subs,sel,config) kara_swift(subs, sel, 1) end,
		function(subs,sel,config) kara_swift(subs, sel, 2) end,
		function(subs,sel,config) aegisub.cancel() end
	},
	
	wchar_dialogs = {
		info = { 0, 0, 1, 1, "label", label = "��ǩ����" },
		{ 1, 0, 1, 1, "dropdown", name = "tag", items = {"\\kf", "\\k", "\\ko"} , value = "\\kf" }
	},
	wchar_buttons = {"OK", "Cancel"},
	wchar_commands = {
		function(subs,sel,config) kara_parse_wchar(subs, sel, config) end,
		function(subs,sel,config) aegisub.cancel() end,
	},
	
	strip_dialogs = {
		info = { 0, 0, 1, 1, "label", label = "" , },
		{ 0, 1, 1, 1, "checkbox", name = "allstrip", value = false, label = "������п���OK���ڷ�"  },
	},
	strip_buttons = {"OK", "Cancel"},
	strip_commands = {
		function(subs,sel,config) kara_strip_tags(subs, sel, config) end,
		function(subs,sel,config) aegisub.cancel() end,
	},
	
	sylmov_dialogs = {
		info = { 0, 0, 5, 1, "label", label = "" },
		{ 0, 1, 1, 1, "dropdown", name = "tp", items = {"��ǰ", "�Ӻ�"}, value = "��ǰ" },
		{ 1, 1, 1, 1, "intedit", name = "duration", hint = "", value = 0, min = 0, max = 20000 },
		{ 1, 1, 1, 1, "label", label = "ms" }
	},
	sylmov_buttons = {"OK", "Cancel"},
	sylmov_commands = {
		function(subs,sel,config) kara_sylmov(subs, sel, config) end,
		function(subs,sel,config) aegisub.cancel() end,
	},
	
	tlorg_ctrl_dialogs = {
		{ 0, 0, 1, 1, "label", label = "�ؼ�" },
		{ 1, 0, 1, 1, "label", label = "�������" },
		{ 2, 0, 1, 1, "label", label = "ͬ�����" },
		{ 3, 0, 1, 1, "label", label = "��Ļ��ʽ" },
		{ 4, 0, 1, 1, "label", label = "��Ļ�ı�" },
	},
	tlorg_ctrl_buttons = {"Save", "Refresh",  "Preview", "Auto", "Cancel"},
	tlorg_ctrl_commands = function(subs,sel,button,config) return button, config end,
}

--[[
function main(mode, subs, sel)
	if mode == "kara_parse_double" then
		show_dialog(subs, sel, 'double_dialogs', 'double_buttons', 'double_commands')
	elseif mode == "kara_swift" then
		show_dialog(subs, sel, 'swift_dialogs', 'swift_buttons', 'swift_commands')
	end
end

function entry(subs, sel)
	show_dialog(subs, sel, 'main_dialogs', 'main_buttons', 'main_commands', '')
end
--]]

function kara_parse_double(subs, sel, config)		
	local flag = {
		[1] = 0,
		[2] = 0,
		[3] = 0,
	}
	local timeadv = config.timeadv
	local timepass = config.timepass
	local s = {}
	local durations = {}--ǰ��ʱ��
	
	for i = 1, #sel do
		-- ��һ�� ʱ����ȫ��ǰ��ָ��ʱ��
		s[i] = subs[sel[i]]
		s[i].start_time = s[i].start_time - timeadv
		--s[i].name = string.format("%s,%s",s[i].start_time,s[i].end_time)
		durations[i] = timeadv	
		flag[1] = flag[1] + 1
	end
	
	for i = 1, #sel do		
		-- �ڶ��� ���н���ʱ���ӳ������еĿ�ʼʱ��
		
		if i <= #sel-2 then
			drt = s[i+2].start_time - s[i].end_time
			if config.fn1 and drt < 0 then--ͬһλ�õ�ǰ���ʱ���ͻʱ
				durations[i+2] = durations[i+2] + drt
				s[i+2].start_time = s[i].end_time
				flag[3] = flag[3] + 1
			else
				if drt > timepass then
					s[i].end_time = s[i].end_time + timepass
				else
					s[i].end_time = s[i+2].start_time
				end				
				flag[2] = flag[2] + 1
			end			
		else
			s[i].end_time = s[i].end_time + timepass
			flag[2] = flag[2] + 1
		end		
	end
		
	for i = 1, #sel do
		-- ������ д����и�ʵ�ǰ����Ч
		s[i].text = string.format("{\\k%d}%s", math.floor(durations[i]/10), s[i].text)
		subs[sel[i]] = s[i]
	end
	
	if flag then
		aegisub.debug.out(0, "����ɹ���ɡ�\nǰ����%s�С�\nͨ���ӳ���%s�С�\n�ӳ���������%s�С�", flag[1], flag[2], flag[3])
		
		aegisub.set_undo_point(script_name)
	else
		aegisub.debug.out(0, "û�н����޸�")
	end
end

function kara_parse_wchar(subs, sel, config)--���ַ��Զ���������
	local unicode = require 'aegisub.unicode'
	local s = {}
	local TLSubs = read_syllables(subs, sel)
	--write_syllables(subs, sel, tp)
	aegisub.progress.task("Processing...")
	aegisub.progress.set(0)
	for i = 1, #TLSubs do
		local subp = TLSubs[i]
		if #subp["syllables"] == 1 and subp["syllables"][1].duration == 0 then--ֻ����û�����ڴ���ʱ��ִ��
			local sw0 = ""
			local sw = {}
			local length = unicode.len(subp.text)
			local j = 1
			for chr in unicode.chars(subp.text) do--����unicode������ascii���Ȳ�ͬ���ж��Ƿ���ַ�/���ʣ���������������飬�ﵽ�������ڵ�Ŀ��
				if j >= length then
					table.insert(sw, sw0..chr)
				elseif chr == ' ' and string.len(sw0) > 0 then
					table.insert(sw, sw0..' ')
					sw0 = ''
				elseif unicode.len(chr) ~= string.len(chr) then
					if string.len(sw0) > 0 then
						table.insert(sw, sw0)
						sw0 = ''
					end
					table.insert(sw, chr)
				else
					sw0 = sw0..chr
				end
				j = j + 1
			end
			if #sw == 0 then
				table.insert(sw, sw0)
			end
			local interval = math.floor((subp.end_time - subp.start_time) / #sw)--����ƽ�����ʱ��
			for k,subsw in pairs(sw) do			--д��ȫ�ֺ���
				TLSubs[i]["syllables"][k] = {
					duration = interval,
					tag = config.tag,
					text = subsw
				}
			end
		end
		aegisub.progress.set(1 / #TLSubs)
	end
	write_syllables(subs, sel, TLSubs)
end

function kara_strip_tags(subs, sel, config)--ȥ������OK��ǩ����ά��ԭ����start_time��end_time
	local TLSubs = read_syllables(subs, sel)
	for i = 1, #TLSubs do
		local subp = TLSubs[i]
		local syls = subp["syllables"]
		if syls[#syls].duration > 20 and syls[#syls].text == '' then --���ж�β������Ϊʱ��С�ڵ���20ms�Ķ���ռλ��������
			subp.end_time = subp.end_time - syls[#syls].duration
			table.remove(TLSubs[i]["syllables"],#syls)
		end
		if syls[1].duration > 0 and syls[1].text == '' then --���ж�ͷ�����������޸�����
			subp.start_time = subp.start_time + syls[1].duration
			table.remove(TLSubs[i]["syllables"],1)
		end
		if config.allstrip then --���ʣ�����п���OK��ǩ���ǲ��޸�ʱ��
			local syls_temp = ""
			for j=1, #syls do
				syls_temp = syls_temp..syls[j].text
			end
			TLSubs[i]["syllables"] = {
				{
					tag = "\\kf",
					duration = 0,
					text = syls_temp
				}				
			}
		end
	end
	write_syllables(subs, sel, TLSubs)
end

function kara_swift(subs, sel, tp)
	if tp == 0 then
		for i = 1, #sel do
			local sub = subs[sel[i]]--TODO:ʵ���������ã���ôдû����
			local subp = subs[sel[i]]
			aegisub.parse_karaoke_data(subp)
			local effect = ''
			for j = 1, #subp do
				effect = effect..subp[j].text..' '
			end
			sub.effect = effect
			subs[sel[i]] = sub
		end
	elseif tp == 1 then
		for i = 1, #sel do
			local sub = subs[sel[i]]
			local subp = subs[sel[i]]
			local subtext = ''
			aegisub.parse_karaoke_data(subp)
			local effect = sub.effect
			if string.len(effect) > 0 then
				effect = LuaSplit(effect,' ')
				for j = 1, #subp do
					subtext = subtext..string.format("{%s%d}%s", subp[j].tag, subp[j].duration/10, effect[j])
					--subtext = subtext..'{'..string.char(92)..subp[j].tag..(subp[j].duration/10)..'}'..effect[j]
				end
			end
			sub.text = subtext
			subs[sel[i]] = sub
		end
	elseif tp == 2 then
		for i = 1, #sel do
			local sub = subs[sel[i]]
			sub.effect = ''
			subs[sel[i]] = sub
		end
	end
end
--TODO: �м��ϵ��
--Head-�ؼ��䣬��Ϊ�ؼ������R��ֵ�ľ���
--column-ͬ����C��ͬ��ǵĺ�����ֹʱ������ڶ����ؼ������
--row-������R��ͬ��ǵĽ�������Ϊ�˴���ǰ��������ϵ
--{"C" = 3, "R" = 5��"H" = 1}����

--���̣�ִ�С�Ԥ����ʽ��Ԥ����ʽ���еĹ�ϵ����ʾ�������ڡ�ȷ����д��effect
--TODO: ��repeat...until...ʵ�ֱ༭����
--TODO: �Զ�����Ƿ��Ѿ���ϵ������ϵ���Ϸ���
function timeline_org_main(subs, sel)
	local TLSubs = read_syllables(subs, sel)
	local styles, headstyle = timeline_org_prepare(TLSubs)--�õ�style�б��Ԥ���Ĺؼ�����ʽ
	local rmax, rnum = 9, 1
	local TLRels = timeline_create_rels(TLSubs, headstyle, styles)--���ɹؼ����ϵ��
	timeline_parse_rows(TLSubs, TLRels, styles, headstyle, rnum)--�����й�ϵ
	local cmax = timeline_parse_columns(TLSubs, TLRels, styles)--�����й�ϵ
	local button, config = "", {}
	while(button and button ~= "Save" and button ~= "Cancel") do--��ѭ���ﵽ������ʾ����Ч��
		
		button, config = timeline_org_ctrl_dialog(subs, sel, TLSubs, TLRels, styles, headstyle, rmax, rnum, cmax)
		if button == "Auto" then--�����Զ��趨��������
			headstyle = config.headstyle
			rnum = tonumber(config.rnum)
			TLRels = timeline_create_rels(TLSubs, headstyle, styles)--���ɹؼ����ϵ��
			timeline_parse_rows(TLSubs, TLRels, styles, headstyle, rnum)--�����й�ϵ
			cmax = timeline_parse_columns(TLSubs, TLRels, styles)--�����й�ϵ
		end
		--button, config = rst[1], rst[2]
		--aegisub.debug.out(0, button)
	end
	--local config1 = timeline_org_1_dialog(subs, sel, styles, headstyle)--��ʾ��ʽ�Ի���
	--if (config1.head ~= headstyle) then headstyle = config1.head end--ȷ��head����ʽ�Ĺ�ϵ
	--local rnum = config1.rnum--ȷ��row��Ϊ����
	if button == "Save" then
		timeline_org_update(TLSubs, TLRels)
		write_syllables(subs, sel, TLSubs)
	end	
end

function timeline_org_prepare(TLSubs)
	local styles = {}
	local headstyle = ""
	for i = 1, #TLSubs do
		local subp = TLSubs[i]
		s = subp.style
		if(not styles[s]) then
			styles[s] = 1
		end
		if headstyle == "" and #subp["syllables"] > 1 then headstyle = subp.style end--��һ������������1�ľ�Ϊ�ؼ���
	end
	local styles = table_keys(styles)
	if headstyle == "" then headstyle = styles[1] end--ǰ��ûѡ���ؼ�������
	
	return styles, headstyle
end

function timeline_create_rels(TLSubs, headstyle, styles)--���ɹؼ����ϵ����ΪR������ؼ���
	local TLRels = {}
	for i = 1, #TLSubs do
		local rel = {}
		if TLSubs[i]["style"] == headstyle then
			rel["R"] = 99
		end
		TLRels[i] = rel
	end
	return TLRels
end

function timeline_parse_rows(TLSubs, TLRels, styles, headstyle, rnum)
	local r = 1
	for i = 1, #TLSubs do
		local subp = TLSubs[i]
		if subp.style == headstyle then
			local rel = TLRels[i]
			rel["R"] = r
			if r >= rnum then
				r = 1
			else
				r = r + 1
			end
			TLRels[i] = rel	
		end		
	end
end

function timeline_parse_columns(TLSubs, TLRels, styles)--�����й�ϵ��ͬʱ�����������
	local style_proc = {}
	for _, v in pairs(styles) do
		style_proc[v] = 1
	end
	for i = 1, #TLSubs do
		local subp = TLSubs[i]
		local rel = TLRels[i]
		rel["C"] = style_proc[subp.style]
		style_proc[subp.style] = style_proc[subp.style] + 1
		TLRels[i] = rel
	end	
	local cmax = 1
	for _, v in pairs(style_proc) do
		if v > cmax then cmax = v end
	end
	return cmax
end

function timeline_org_ctrl_dialog(subs, sel, TLSubs, TLRels, styles, headstyle, rmax, rnum, cmax)
	local showlines = util.deep_copy(UI_conf["tlorg_ctrl_dialogs"])
	local lnum = 1
	aegisub.progress.task("Creating Dialog...Please Wait")
	aegisub.progress.set(0)
	for i = 1, #TLSubs do
		local subp = TLSubs[i]
		local relp = TLRels[i]
		--local newline = util.deep_copy(UI_conf["tlorg_ctrl_dialog_edit_elements"])
		local hv, cv
		if TLRels[i]["R"] then 
			hv = true
			rv = TLRels[i]["R"]
		else
			hv = false
			rv = 0
		end
		local newline = {
			{ 0, i, 1, 1, "checkbox", name = "head_" .. i, value = hv },
			{ 1, i, 1, 1, "intedit", name = "row_" .. i,  value = rv, min = 0, max = rmax },
			{ 2, i, 1, 1, "intedit", name = "col_" .. i,  value = TLRels[i]["C"], min = 1, max = cmax },
			--{ 1, y, 1, 1, "dropdown", name = "row_" .. i, items = rlist, value = rv },
			--{ 2, y, 1, 1, "dropdown", name = "col_" .. i, items = clist, value = TLRels[i]["C"] },
			{ 3, i, 1, 1, "edit", name = "style_" .. i, text = subp.style },
			{ 4, i, 30, 1, "edit", name = "text_" .. i, text = subp.text }
		}	
		array_plus(showlines, newline)
		lnum = lnum + 1
		aegisub.progress.set(i / (#TLSubs + 2) * 100)
	end
	--aegisub.debug.out(0, table_serialize(showlines))
	local settingline = {
		{ 0, lnum, 1, 1, "label", label = "----" },
		{ 1, lnum, 1, 1, "label", label = "----------------" },
		{ 2, lnum, 1, 1, "label", label = "----------------" },
		{ 3, lnum, 1, 1, "label", label = "----------------" },
		{ 0, lnum + 1, 1, 1, "label", label = "������" },--��Ҫ�޸�y
		{ 1, lnum + 1, 1, 1, "dropdown", name = "rnum", items = table_make_array(rmax), value = rnum },--��Ҫ�޸�y��items��value
		{ 2, lnum + 1, 1, 1, "label", label = "�ؼ���ʽ" },--��Ҫ�޸�y
		{ 3, lnum + 1, 1, 1, "dropdown", name = "headstyle", items = styles, value = headstyle }--��Ҫ�޸�y��name��items��value
	}
	aegisub.progress.set(100)
	array_plus(showlines, settingline)
	return show_dialog(subs, sel, showlines, 'tlorg_ctrl_buttons', 'tlorg_ctrl_commands')
end

function timeline_org_update(TLSubs, TLRels)
	for i = 1, #TLSubs do
		local subp = TLSubs[i]
		if TLRels[i] and TLRels[i] ~= {} then
			subp.effect =table_serialize(TLRels[i])
		end		 
	end
	return TLSubs
end

--2. �����е��������޸Ĳ�д��

--Ԥ����ʽ
function timeline_read_styles(subs, sel, TLSubs)
	
	return styles, headstyle
end

--�������е���ʼ�ͽ���ʱ��д��effect��
--[[
function write_timeline_times(subs, sel)
	local TLSubs = read_syllables(subs, sel)
	for i = 1, #TLSubs do
		local subp = TLSubs[i] 
		local otimeline = {
			start_time = subp.start_time,
			end_time = subp.end_time
		}
		subp.effect = table_serialize(otimeline)
	end
	write_syllables(subs, sel, TLSubs)
end
--]]

--��ǰ���Ӻ���ʼ�ͽ���ʱ�䣬���ı����ڣ�
--drt����Ϊ��ǰ������Ϊ�Ӻ�
--tp1=nil��0Ϊ���ƶ���1Ϊֻ�ƶ���ʼ��2Ϊֻ�ƶ�������3Ϊ���ƶ���
--tp2=nil��0Ϊ�������ͻ��1Ϊ���ı�ǰ��ʱ�䣬2Ϊ���ı���ʱ��
--tp3=nil��0Ϊ���޸����ڣ�1Ϊ�Զ���ӿ�����ռλ��
function move_timelines(subs, sel, drt, tp1, tp2, tp3)
	local TLSubs = read_syllables(subs, sel)
	if tp1 or tp1 ~= 0 then
		for i = 1, #TLSubs do--�ڶ���ѭ������ʱ������޸�
			local subp = TLSubs[i]
			if tp1 == 1 or tp1 == 3 then
				subp.start_time = subp.start_time + drt
			end
			if tp1 == 2 or tp1 == 3 then
				subp.end_time = subp.end_time + drt
			end
		end
	end
	if tp2 or tp2 ~= 0 then
		for i = 1, #TLSubs do--������ѭ���������ͻ
			
		end
	end
	write_syllables(subs, sel, TLSubs)
end

--�����ƶ��ĿǺ���
function kara_sylmov(subs, sel, config)
	local drt = 0
	if config.tp == "��ǰ" then
		drt = - config.duration
	elseif config.tp == "�Ӻ�" then
		drt = config.duration
	end
	move_syllables(subs, sel, drt)
end

--����ʼ�ͽ���ʱ�䲻���ǰ���£���ǰ���Ӻ����ڻ����ߣ�drt����Ϊ��ǰ������Ϊ�Ӻ�
function move_syllables(subs, sel, drt, tp)
	local TLSubs = read_syllables(subs, sel)
	for i = 1, #TLSubs do
		local subp = TLSubs[i]
		local syls = subp["syllables"]
		if #syls > 1 then
			local drt1 = drt
			if drt1 < 0 then
				for j = 1, #syls do--��ǰ��һ��ѭ��
					local syldrt = syls[j].duration
					if syldrt + drt1 < 0 then--�����ڲ�����ǰ������¸����ڹ��㣬������ǰ��һ������
						syls[j].duration = 0
						drt1 = drt1 + syldrt
					else--������������ǰ�������ֻ��Ҫ�޸ĵ�ǰ����
						syls[j].duration = syls[j].duration + drt1
						drt1 = 0
						break
					end				
				end
				local subdrt = subp.end_time-subp.start_time
				local sum = 0
				for j = 1, #syls do--�ڶ���ѭ��������������ʱ�䣬�Ѳ�ֵ�ӵ����һ������
					sum = sum + syls[j].duration
				end
				syls[#syls].duration = syls[#syls].duration + subdrt - sum
			elseif drt1 > 0 then--�Ӻ��һ��ѭ��
				for j = #syls, 1, -1 do
					local syldrt = syls[j].duration
					if syldrt - drt1 < 0 then--�����ڲ����Ӻ������¸����ڹ��㣬�����Ӻ�ǰһ������
						syls[j].duration = 0
						drt1 = drt1 - syldrt
					else--�����������Ӻ�������ֻ��Ҫ�޸ĵ�ǰ����
						syls[j].duration = syls[j].duration - drt1
						drt1 = 0
						break
					end		
				end
				local subdrt = subp.end_time-subp.start_time
				local sum = 0
				for j = 1, #syls do--�ڶ���ѭ��������������ʱ�䣬�Ѳ�ֵ�ӵ���һ������
					sum = sum + syls[j].duration
				end
				syls[1].duration = syls[1].duration + subdrt - sum
			end	
		end		
	end
	write_syllables(subs, sel, TLSubs)
end

--�����ں�������̨���ı���ȡÿ���Լ�ÿ�����ڵ����ݣ�ʹ��parse_karaoke_data()������������������
function read_syllables(subs, sel, tp)
	local sublist = {}
	aegisub.progress.task("Reading Lines...")
	aegisub.progress.set(0)
	for i = 1, #sel do
		local subp = subs[sel[i]]
		if subp.text ~= '' and not subp.comment then--���к�ע���в��ᱻ��ȡ 
			local sylp = subs[sel[i]]
			sublist[i] = {
				start_time = subp.start_time,
				end_time = subp.end_time,
				text = subp.text,
				style = subp.style,
				effect = subp.effect,
				syllables = {}
			}
			if subp.effect then 
				sublist[i]["rel"] = table_unserialize(subp.effect)--˳����ͼ���л��м��ϵ�������������Ϊnil
			else
				sublist[i]["rel"] = nil
			end
			aegisub.parse_karaoke_data(sylp)
			for j = 1, #sylp do
				sublist[i]["syllables"][j] = sylp[j]
			end
		end		
		aegisub.progress.set(i / #sel * 100)
	end
	return sublist
end

--д���ں�������������������д��ѡ����У�ͬʱҲ�����text���ԣ�tpĬ��Ϊfalse��tpΪ1��ʾǿ��д��
function write_syllables(subs, sel, cont, tp)
	local sublist = cont
	aegisub.progress.task("Writing Lines...")
	aegisub.progress.set(0)
	for i = 1, #sublist do
		local sylp = sublist[i]["syllables"]
		local sub = subs[sel[i]]
		local subp = ""
		if tp == 1 or not(#sylp == 1 and sylp[1].duration == 0) then
			for j = 1, #sylp do
				subp = subp..string.format("{%s%d}%s", sylp[j].tag, sylp[j].duration/10, sylp[j].text)
			end
		else --���ַ���ȥ�����׵Ŀ����ڱ��
			subp = sylp[1].text
		end
		sublist[i]["text"] = subp
		sub.start_time = sublist[i]["start_time"]
		sub.end_time = sublist[i]["end_time"]
		sub.text = sublist[i]["text"]
		sub.style = sublist[i]["style"]
		sub.effect = sublist[i]["effect"]
		subs[sel[i]] = sub
		aegisub.progress.set(i / #sublist * 100)
	end
end

--��ʾ�Ի����ͨ�ú���
function show_dialog(subs, sel, dconf, bconf, cconf, info)
	local button, config, rst, rst2
	local Ud, Ub, Uc = dconf, bconf, cconf
	if type(Ud) == "string" then Ud = util.deep_copy(UI_conf[dconf]) end
	if type(Ub) == "string" then Ub = util.deep_copy(UI_conf[bconf]) end
	if type(Uc) == "string" then Uc = util.deep_copy(UI_conf[cconf]) end
	for k, v in pairs(Ud) do
		v.x = v[1]
		v.y = v[2]
		v.width = v[3]
		v.height = v[4]
		v.class = v[5]
	end
	if(info) then 
		Ud['info']['label'] = info
		info = ''
	end
	button, config = aegisub.dialog.display(Ud,Ub)
	if type(Uc) == "table" then
		for i, c in pairs(Uc) do
			if button == Ub[i] then
				rst = c(subs,sel,config)
				break
			end
		end
	elseif type(Uc) == "function" then
		rst, rst2 = Uc(subs,sel,button,config)
	end
	return rst, rst2
end

--�ײ㺯�������л�������ת��Ϊ�ַ���
function table_serialize(tbl)
	local str = '{'
	for k, v in pairs(tbl) do
		local split = ''
		if type(k) == 'number' then
			split = ''
		elseif type(k) == 'string' then
			split = '"'
		end
		str = str .. '[' .. split .. k ..split ..']='
		if type(v) == 'number' then
			str = str .. v .. ',' 
		elseif type(v) == 'string' then
			str = str .. '"' .. v .. '",' 
		elseif type(v) == 'table' then
			str = str .. table_serialize(v) .. ','--���ܴ���ѭ�����ã�����һ����������
		else
			str = str .. 'nil,'
		end
	end
	str = string.sub(str,1,-2)  .. '}'
	return str
end

--�ײ㺯���������л������ַ���ת��Ϊ��
--͵��ֱ��ִ�У��а�ȫ���գ�����˭��Ա��ؽű�����ȥ��
function table_unserialize(str)
	local tbl = nil
	if type(str) == "string" and str ~= "" then
		local str = 'local tbl=' .. str .. ' return tbl'
		rst = assert(loadstring(str))()
		if type(rst) == "table" then tbl = rst end
	end	
  return tbl
end

function table_make_array(n)
	local rst = {}
	for i = 1, n do
		table.insert(rst, i)
	end
	return rst
end

--�ײ㺯�������ر�ļ���
function table_keys(tbl) 
	local ks = {}
	for k, _ in pairs(tbl) do
		table.insert(ks,k)
	end
	return ks
end

--�ײ㺯������ǳ����
function table_search(tbl, val) 
	local pos = nil
	for k, v in pairs(tbl) do
		if v == val then
			pos = k
			break
		end
	end
	return pos
end

--�ײ㺯������ϲ�
function table_merge(tbl1, tbl2)
	for k, v in pairs(tbl2) do
		if type(k) == "number" then
			table.insert(tbl1, v)
		elseif type(k) == "string" then
			tbl1[k] = v
		end
	end
	return tbl1
end

function array_plus(tbl1, tbl2)
	for k, v in ipairs(tbl2) do
		table.insert(tbl1, v)
	end
	return tbl1
end

--�ײ㺯����lua���explode
function LuaSplit(str,split)  
    local lcSubStrTab = {}  
    while true do  
        local lcPos = string.find(str,split)  
        if not lcPos then  
            lcSubStrTab[#lcSubStrTab+1] =  str      
            break  
        end  
        local lcSubStr  = string.sub(str,1,lcPos-1)  
        lcSubStrTab[#lcSubStrTab+1] = lcSubStr  
        str = string.sub(str,lcPos+1,#str)  
    end  
    return lcSubStrTab  
end 
 
--[[
--�ײ㺯��������php���з���
function !(v)
	return not v or v == 0 or v == "" or v == {}
end
--]]

function selection_validation(subs, sel)
	return #sel > 1
end

function test(subs, sel)
	local a = function(subs,sel,button,config) return button end
	button = show_dialog(subs,sel,{},{},"tlorg_ctrl_commands")
	aegisub.debug.out(0, table_serialize(button,' '))
end

--���������		
TLL_macros = {
	{
		script_name = "���ֺ�������",
		script_description = "�Զ�ʶ���ֵȿ��ַ����Կ���OK��ǩ����",
		entry = function(subs, sel) show_dialog(subs, sel, 'wchar_dialogs', 'wchar_buttons', 'wchar_commands') end,
		validation = false
	},
	{
		script_name = "����ռλ����",
		script_description = "ɾ����Ļǰ���ռλ���ڲ���֤ʱ�����ȷ",
		entry = function(subs,sel,config) show_dialog(subs, sel, 'strip_dialogs', 'strip_buttons', 'strip_commands') end,
		validation = false
	},
	{
		script_name = "�����ƶ�����",
		script_description = "���ı���ֹʱ�䣬ͳһ�ƶ���ѡ�����ڵķָ�ʱ��",
		entry = function(subs,sel,config) show_dialog(subs, sel, 'sylmov_dialogs', 'sylmov_buttons', 'sylmov_commands') end,
		validation = false
	},
	{
		script_name = "˫����Ļ",
		script_description = "����˫�п���OK��Ļ",
		entry = function(subs,sel,config) show_dialog(subs, sel, 'double_dialogs', 'double_buttons', 'double_commands') end,
		validation = selection_validation
	},
	{
		script_name = "�����л�",
		script_description = "���������ı�����������ı��޸���Ļ",
		entry = function(subs,sel,config) show_dialog(subs, sel, 'swift_dialogs', 'swift_buttons', 'swift_commands') end,
		validation = false
	},
	{
		script_name = "ʱ�����ϵ��",
		script_description = "������ʽ����ʱ����ͬ���������Ĺ�ϵ��Ϣ",
		entry = function(subs,sel,config) timeline_org_main(subs, sel) end,
		validation = false
	},
}
for i = 1, #TLL_macros do
	aegisub.register_macro(script_name.."/"..TLL_macros[i]["script_name"], TLL_macros[i]["script_description"], TLL_macros[i]["entry"], TLL_macros[i]["validation"])
end
--aegisub.register_macro("TEST", script_description, test)