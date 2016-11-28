import glfw, opengl

const SIZE = 9 

proc log(result: GLuint, `type`: string) =
    var 
        status: GLint 
        getiv = glGetProgramiv
        getInfo = glGetProgramInfoLog
    if type == "glCompileShader":
        getiv = glGetShaderiv
        getInfo = glGetShaderInfoLog

    getiv(result, GL_INFO_LOG_LENGTH, status.addr)
    if status == 0:
        var info = status.int.newString
        getInfo(result, status, nil, info)
        echo(type & " failed: " & info) 

proc loadShader(`type`: GLenum, path: string): GLuint =
    result = glCreateShader(type)
    var src = [path.readFile.string].allocCStringArray
    glShaderSource(result, 1, src, nil) 
    glCompileShader(result)
    result.log("glCompileShader")
    src.deallocCStringArray

proc loadProgram(vertexPath: string, fragmentPath: string): GLuint =
    result = glCreateProgram()
    var
        vertexShader = loadShader(GL_VERTEX_SHADER, vertexPath)
        fragmentShader = loadShader(GL_FRAGMENT_SHADER, fragmentPath)
    glAttachShader(result, vertexShader)
    glAttachShader(result, fragmentShader)
    glLinkProgram(result)
    result.log("glLinkProgram")
    glDetachShader(result, vertexShader)
    glDetachShader(result, fragmentShader)
    glDeleteShader(vertexShader)
    glDeleteShader(fragmentShader)

type Buffer = array[SIZE, float]

proc genBuffer(data: var Buffer): GLuint = 
    glGenBuffers(1, result.addr)
    glBindBuffer(GL_ARRAY_BUFFER, result)
    glBufferData(GL_ARRAY_BUFFER, data.len, data.addr, GL_STATIC_DRAW)

proc main() =
    init()

    var win = newGlWin(title="xero", dim=(w: 800, h:600))
    win.cursorMode = CursorMode.cmDisabled
    makeContextCurrent(win)
    swapInterval(1)

    loadExtensions()
    glClearColor(0, 0, 0.4, 0)

    var vertexArray: GLuint
    glGenVertexArrays(1, vertexArray.addr)
    glBindVertexArray(vertexArray)

    var p = loadProgram("vertex.glsl", "fragment.glsl")

    var verts = [
        -1.0,-1.0, 0.0,
         1.0,-1.0, 0.0,
         0.0, 1.0, 0.0,
    ]
    var vertexBuffer = verts.genBuffer

    while not win.shouldClose:
        glClear(GL_COLOR_BUFFER_BIT)
        glUseProgram(p)

        glEnableVertexAttribArray(0)
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer)
        glVertexAttribPointer(0, 3, cGL_FLOAT, false, 0, nil)

        glDrawArrays(GL_TRIANGLES, 0, 3)

        glDisableVertexAttribArray(0)

        win.swapBufs
        pollEvents()

    terminate()

main()
