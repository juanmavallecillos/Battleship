 
extern "C" char carac;

// Matrius 4x4 per inicialitzar el joc
extern "C" char sea[8][8] = { {1,1,0,0,0,0,0,0},
                           {0,0,0,1,0,0,1,0},
                           {0,0,0,0,0,0,0,0},
                           {0,1,1,0,0,1,0,0},
                           {0,0,0,0,0,1,0,0},
                           {0,0,0,1,0,1,0,0},
                           {0,0,0,0,0,0,0,0},
                           {0,1,1,1,1,0,0,0} };

// Matrius 4x4 on guardem les fitxes del joc.       
extern "C" char taulell[8][8]    = { {' ',' ',' ',' ',' ',' ',' ',' '},
                                     {' ',' ',' ',' ',' ',' ',' ',' '},
                                     {' ',' ',' ',' ',' ',' ',' ',' '},
                                     {' ',' ',' ',' ',' ',' ',' ',' '},
                                     {' ',' ',' ',' ',' ',' ',' ',' '},
                                     {' ',' ',' ',' ',' ',' ',' ',' '},
                                     {' ',' ',' ',' ',' ',' ',' ',' '},
                                     {' ',' ',' ',' ',' ',' ',' ',' '} };

extern "C" char carac2;        //caràcter llegit de teclat i per a escriure a pantalla.
extern "C" int row;			//fila per a accedir a la matriu sea [0..(4-1)]
extern "C" char col;			//columna per a accedir a la matriu sea [A..G]
extern "C" int indexMat; 		//índex per a accedir a la matriu sea (index=row*4+col [0..(sizeMatrix-1)].
extern "C" int indexMatIni;

extern "C" int rowCur   = 4;	//fila del cursor a la matriu sea.
extern "C" char colCur = 'D';	//columna del cursor a la matriu sea.
extern "C" int rowScreen;		//fila on volem posicionar el cursor a la pantalla.
extern "C" int colScreen;		//columna on volem posicionar el cursor a la pantalla.


extern "C" int RowScreenIni;
extern "C" int ColScreenIni;

extern "C" int rowIni;
extern "C" char colIni;


extern "C" int opc;

extern "C" int sunk;
extern "C" int tocat;

