require 'wx'

$borders = {"Default" => Wx::DEFAULT_FRAME_STYLE,
            "Iconize" => Wx::ICONIZE,
            "Caption" => Wx::CAPTION, 
            "Minimize" => Wx::MINIMIZE | Wx::CAPTION,
            "Minimize_Box" => Wx::MINIMIZE_BOX | Wx::SYSTEM_MENU | Wx::CAPTION,
            "Maximize" => Wx::MAXIMIZE,
            "Maximize_Box" => Wx::MAXIMIZE_BOX | Wx::SYSTEM_MENU | Wx::CAPTION,
            "Stay_on_Top" => Wx::STAY_ON_TOP,
            "System_Menu" => Wx::SYSTEM_MENU | Wx::CAPTION,
            "Simple_Border" => Wx::SIMPLE_BORDER,
            "Resize_Border" => Wx::RESIZE_BORDER,
            "Frame_Tool_Window" => Wx::FRAME_TOOL_WINDOW | Wx::SYSTEM_MENU | Wx::CAPTION,
            "Frame_No_Taskbar" => Wx::FRAME_NO_TASKBAR,
            "Double_Border" => Wx::DOUBLE_BORDER}

class StyleFrame < Wx::Frame
    def initialize(name,style)
        super(nil, -1, name, Wx::Point.new(400,100), Wx::Size.new(400,400), style)
        panel = Wx::Panel.new(self, -1, Wx::Point.new(0,0), Wx::Size.new(400,400))
        btn = Wx::Button.new(panel, -1, name + " (Close me)", Wx::Point.new(45,55))
        evt_button(btn.get_id()) {|event| destroy()}
    end
end

class FrameMaker < Wx::Frame
    def initialize()
        super(nil, -1, "Frame Maker", Wx::DEFAULT_POSITION, Wx::Size.new(300,350))
        @name = "Default"
        
        panel = Wx::Panel.new(self, -1)
        names = $borders.keys().sort()
        @styleBox = Wx::RadioBox.new(panel, -1, "&Frame Styles", Wx::Point.new(20,5), Wx::DEFAULT_SIZE, names, 1, Wx::RA_SPECIFY_COLS)
        evt_radiobox(@styleBox.get_id()) {|event| on_radio(event)}
        @styleBox.set_selection(1)
        btn = Wx::Button.new(panel, -1, "Create Frame", Wx::Point.new(175,15))
        evt_button(btn.get_id()) {|event| on_create(event)}
        show()
    end
    
    def on_radio(event)
        @name = @styleBox.get_string_selection()
    end
    
    def on_create(event)
        StyleFrame.new(@name, $borders[@name]).show()
    end
end

class MyApp < Wx::App
    def on_init()
        frame = FrameMaker.new()
    end
end

app = MyApp.new()
app.main_loop()