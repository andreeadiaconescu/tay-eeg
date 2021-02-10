function glVertexAttribL4ui64NV( index, x, y, z, w )

% glVertexAttribL4ui64NV  Interface to OpenGL function glVertexAttribL4ui64NV
%
% usage:  glVertexAttribL4ui64NV( index, x, y, z, w )
%
% C function:  void glVertexAttribL4ui64NV(GLuint index, GLuint64EXT x, GLuint64EXT y, GLuint64EXT z, GLuint64EXT w)

% 30-Sep-2014 -- created (generated automatically from header files)

if nargin~=5,
    error('invalid number of arguments');
end

moglcore( 'glVertexAttribL4ui64NV', index, x, y, z, w );

return
