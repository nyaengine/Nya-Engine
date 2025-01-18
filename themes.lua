local themes = {}
themes.__index = themes

UIClrs = {1, 0.4, 0.7}
UIClrsTB = {1, 0.4, 0.7, 0.5}
UIButtonColors = {0.8, 0.3, 0.6}
UIButtonHoverColors = {1, 0.4, 0.7}
UILabelBGColor = {0.8, 0.3, 0.6}
WindowsColors = {1, 0.4, 0.7}
WindowsLineClr = {0.6, 0.1, 0.3}

function themes:applyTheme(theme)
	if theme == "Nya Mode" then
		UIClrs = {1, 0.4, 0.7}
		UIClrsTB = {1, 0.4, 0.7, 0.5}
		UIButtonColors = {0.8, 0.3, 0.6}
		UIButtonHoverColors = {1, 0.4, 0.7}
		UILabelBGColor = {0.8, 0.3, 0.6}
		WindowsColors = {1, 0.4, 0.7}
		WindowsLineClr = {0.6, 0.1, 0.3}
	elseif theme == "Dark Mode" then
		UIClrs = {0.1, 0.1, 0.1}
        UIClrsTB = {0.1, 0.1, 0.1, 0.5}
        UIButtonColors = {0.3, 0.3, 0.3}
		UIButtonHoverColors = {0.4, 0.4, 0.4}
		UILabelBGColor = {0.3, 0.3, 0.3}
		WindowsColors = {0.1, 0.1, 0.1}
		WindowsLineClr = {0.3, 0.3, 0.3}
	end
end

return themes