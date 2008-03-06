require 'wxruby2'

class EventFrame < Wx::Frame
    def initialize()
        super(nil, -1, "Event Frame")
        @idleCounter = 0
        evt_close {|event| on_close(event)}
#         evt_idle {|event| on_idle(event)}
        evt_size {|event| on_size(event)}
        evt_key_down {|event| on_key(event)}
        evt_left_down {|event| on_left_down(event)}
        # You can still process these events, you just need to define a separate callback for middle_down and right_down
        # to process them as separate events
        evt_middle_down {|event| on_middle_down(event)}
        evt_right_down {|event| on_right_down(event)}
        
        button = Wx::Button.new(self, -1, "Push me")
        evt_button(button.get_id()) {|event| on_button(event)}
        
        show()
    end

    def message(text, title)
        m = Wx::MessageDialog.new(self, text, title, Wx::OK | Wx::ICON_INFORMATION)
        m.show_modal()
    end
    
    def on_close(event)
        message("This frame will be closed after you push ok", "Close event")
        #close(true) - Don't call this - it will call on_close again, and your application will be caught in an infinite loop
        # Either call event.skip() to allow the Frame to close, or call destroy(), as follows
        destroy()
    end
    
    def on_idle(event)
        @idleCounter += 1
        if @idleCounter > 15 # Without the counter to slow this down, Idle events would be firing every second
            message("The system is idle right now", "Idle event")
            @idleCounter = 0
        end
        event.request_more() # You must include this, otherwise the Idle event won't occur again
    end
    
    def on_size(event)
        size = event.get_size()
        x = size.x
        y = size.y
        message("X = " + x.to_s + ", Y = " + y.to_s, "Size event")
    end
    
    def on_key(event)
        message("Key pressed", "Key Event")
    end
    
    def on_left_down(event)
        button = ""
        if event.left_down()
            button = "Left"
        end
        message(button + " button was clicked", "Mouse event")
    end
    
    def on_middle_down(event)
        # This method hasn't been implemented yet...
        #if event.middle_down()
           #button = "Middle"
        #end
        message("Middle button was clicked", "Mouse event")
    end
    
    def on_right_down(event)
        # This method hasn't been implemented yet...
        #if event.right_down()
            #button = "Right"
        #end
        message("Right button was clicked", "Mouse event")
    end
    
    def on_button(event)
        message("Button was clicked", "Button event")
    end
end

class MyApp < Wx::App
    def on_init
        EventFrame.new()
    end
end

MyApp.new.main_loop