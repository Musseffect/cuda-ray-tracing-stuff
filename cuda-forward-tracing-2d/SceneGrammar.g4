
grammar SceneGrammar;

number: value=(FLOAT|INT);
scene: (statement)* EOF;


statement: id = ID LCRL keyValuePair* RCRL;
keyValuePair: key = ID ASSIGN value = constant SEMICOLON;

vec2: VEC3 LPAREN x = number COMMA y = number RPAREN
vec3: VEC3 LPAREN x = number COMMA y = number COMMA z = number RPAREN
color: COLOR LPAREN r = number COMMA g = number COMMA b = number RPAREN
mat3Row: LPAREN x = number COMMA y = number COMMA z = number RPAREN
mat3: MAT3 LPAREN a1 = mat3Row COMMA a2 = mat3Row COMMA a3 = mat3Row RPAREN 
mat2Row: PAREN x = number COMMA y = number RPAREN
mat2: MAT2 LPAREN a1 = mat3Row COMMA a2 = mat3Row RPAREN 

constant: number
| color
| mat3 
| mat2
| vec2
| vec3
;
expression: func=ID LPAREN functionArguments RPAREN	#FunctionExpression
	| id=ID		#IdentifierExpression
	| value=constant	#ConstantExpression
	;


functionArguments: expression (COMMA expression)* | ;


/*

scene: (command)* EOF;
command: commandName=ID COLON commandArguments SEMICOLON;
commandArguments: value=argument commandArguments | ;
argument: constant|ID;



pointLight: 1.0 2.0
*/

fragment LOWERCASE  : [a-z] ;
fragment UPPERCASE  : [A-Z] ;
fragment DIGIT: [0-9] ;

VEC3: "vec3";
VEC2: "vec2";
MAT2: "mat2";
MAT3: "mat3";
COLOR: "color";

FLOAT: (DIGIT+ DOT DIGIT*) ([Ee][+-]? DIGIT+)?
	   |DOT DIGIT+ ([Ee][+-]? DIGIT+)?
		;
INT: DIGIT+ ; 
ID		: [_]*(LOWERCASE|UPPERCASE)[A-Za-z0-9_]*;
LPAREN:'(';
RPAREN:')';
LCRL:'{';
RCRL:'}';
COMMA: ',' ;
DOT: '.';
SEMICOLON: ';';
ASSIGN: '=';
COLON:':';

NEWLINE	: ('\r'? '\n' | '\r')+ -> skip;
WHITESPACE : (' ' | '\t')+ -> skip ;