//-----------------------------------------------------------------------------
//-- Reproductor de melodias almacenadas en memoria rom
//-- Los 8 bits menos significativos de la nota se sacan por los leds
//-----------------------------------------------------------------------------
//-- (C) BQ. October 2015. Written by Juan Gonzalez
//-----------------------------------------------------------------------------
//-- GPL license
//-----------------------------------------------------------------------------

//-- Incluir las constantes del modulo del divisor
`include "divider.vh"

//-- Parameteros:
//-- clk: Reloj de entrada de la placa iCEstick
//-- ch_out: Canal de salida
module romnotes(input wire clk, 
                output wire [7:0] leds,
                output wire ch_out0,
		output wire ch_out1);

//-- Parametros
//-- Duracion de las notas
parameter DUR = `T_150ms;

//-- Fichero con las notas para cargar en la rom
parameter ROMFILE0 = "cantina-right-hand.list";
parameter ROMFILE1 = "cantina-left-hand.list";

//-- Tamaño del bus de direcciones de la rom
parameter AW0 = 9;

//-- Tamaño de las notas
parameter DW0 = 16;

//-- Tamaño del bus de direcciones de la rom
parameter AW1 = 9;

//-- Tamaño de las notas
parameter DW1 = 16;

//-- Cables de salida de los canales
wire ch0, ch1, ch2;

//-- Selección del canal del multiplexor
reg [AW0-1: 0] addr = 0;
reg [AW1-1: 0] addr = 0;

//-- Reloj con la duracion de la nota
wire clk_dur;
reg rstn = 0;

wire [DW0-1: 0] note0;
wire [DW1-1: 0] note1;

//-- Instanciar la memoria rom
genrom 
  #( .ROMFILE(ROMFILE0),
     .AW(AW0),
     .DW(DW0))
  ROM0 (
        .clk(clk),
        .addr(addr),
        .data(note0)
      );

genrom 
  #( .ROMFILE(ROMFILE1),
     .AW(AW1),
     .DW(DW1))
  ROM1 (
        .clk(clk),
        .addr(addr),
        .data(note1)
      );

//-- Generador de notas
notegen
  CH0 (
    .clk(clk),
    .rstn(rstn),
    .note(note0),
    .clk_out(ch_out0)
  );

//-- Generador de notas
notegen
  CH1 (
    .clk(clk),
    .rstn(rstn),
    .note(note1),
    .clk_out(ch_out1)
  );

//-- Sacar los 8 bits de la nota por los leds
assign leds = note0[7:0];

//-- Inicializador
always @(posedge clk)
  rstn <= 1;


//-- Contador para seleccion de nota
always @(posedge clk)
  if (clk_dur)
    addr <= addr + 1;

//-- Divisor para marcar la duración de cada nota
dividerp1 #(DUR)
  TIMER0 (
    .clk(clk),
    .clk_out(clk_dur)
  );


endmodule



