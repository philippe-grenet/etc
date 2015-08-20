set confirm off
#set verbose off

define colors
    set prompt \033[1;35m(gdb) \033[0m
end

define breakpoints
    info breakpoints
end
document breakpoints
    List all breakpoints.
end
