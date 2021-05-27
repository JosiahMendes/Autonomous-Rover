-- Legal Notice: (C)2006 Altera Corporation. All rights reserved.  Your
-- use of Altera Corporation's design tools, logic functions and other
-- software and tools, and its AMPP partner logic functions, and any
-- output files any of the foregoing (including device programming or
-- simulation files), and any associated documentation or information are
-- expressly subject to the terms and conditions of the Altera Program
-- License Subscription Agreement or other applicable license agreement,
-- including, without limitation, that your use is for the sole purpose
-- of programming logic devices manufactured by Altera and sold by Altera
-- or its authorized distributors.  Please refer to the applicable
-- agreement for further details.

LIBRARY IEEE, ALTERA;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE STD.textio.ALL;

USE altera.ALT_CUSP161_PACKAGE.ALL;

ENTITY ALT_CUSP161_AU IS
  GENERIC (
        NAME         : STRING := "";
        SIMULATION   : INTEGER := SIMULATION_OFF;
        OPTIMIZED    : INTEGER := OPTIMIZED_ON;
        FAMILY       : INTEGER := FAMILY_STRATIX;
        WIDTH        : INTEGER := 16;
        LATENCY      : INTEGER := 1
  );
  PORT (
        clock     : IN STD_LOGIC;
        reset     : IN STD_LOGIC;
        
        ena       : IN STD_LOGIC := '1';
    
        a         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
        b         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
        l         : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
        
        q         : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0);
        
        enable    : IN STD_LOGIC := '0';
        enable_en : IN STD_LOGIC := '0';
                
        sclr      : IN STD_LOGIC := '0'; 
        sload     : IN STD_LOGIC := '0'; 
        subNadd   : IN STD_LOGIC := '0'
  );
END;


ARCHITECTURE rtl OF ALT_CUSP161_AU IS

  SIGNAL a_x    : STD_LOGIC_VECTOR( WIDTH DOWNTO 0);
  SIGNAL b_x    : STD_LOGIC_VECTOR( WIDTH DOWNTO 0);
  SIGNAL l_x    : STD_LOGIC_VECTOR( WIDTH DOWNTO 0);

  SIGNAL a_x_us : UNSIGNED( WIDTH DOWNTO 0);
  SIGNAL b_x_us : UNSIGNED( WIDTH DOWNTO 0);
  SIGNAL l_x_us : UNSIGNED( WIDTH DOWNTO 0);

  SIGNAL r_val_us: UNSIGNED( WIDTH DOWNTO 0);
  SIGNAL r_val  : STD_LOGIC_VECTOR( WIDTH DOWNTO 0);

  SIGNAL q_int    : STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);  

  -- control signals
  SIGNAL trigger : STD_LOGIC; -- do anything
  SIGNAL do_sload   : STD_LOGIC;  -- load from the logic unit
  SIGNAL do_add  : STD_LOGIC;     -- do add if '1', sub if '0'
  SIGNAL do_sclr : STD_LOGIC;
  
BEGIN
    
    do_add        <= not subNadd;
    do_sload      <= sload;
    do_sclr		 <= sclr;
    
    comb_trigger: IF  LATENCY /= 0 GENERATE
        trigger       <= ena and enable and enable_en;
    END GENERATE;
    
    a_x_gen: PROCESS (a)
    BEGIN
      a_x(0) <= '0';
      a_x(WIDTH downto 1) <= a;
      --a_x(WIDTH+1) <= '0';
    END PROCESS;
    
    b_x_gen: PROCESS (b)
    BEGIN
      b_x(0) <= '0';    
      b_x(WIDTH DOWNTO 1) <= b;
      --b_x(WIDTH+1) <= '0';
    END PROCESS;
    
    l_x_gen : PROCESS (l)
    BEGIN
      l_x(0) <= '0';
      l_x(WIDTH DOWNTO 1) <= l;
    END PROCESS;

    a_x_us_gen:  a_x_us <= unsigned(a_x);
    b_x_us_gen:  b_x_us <= unsigned(b_x);

    comb_addsub: IF  LATENCY = 0 GENERATE
      r: PROCESS(l_x, a_x_us, b_x_us, do_add, do_sload, do_sclr)
      BEGIN
            IF (do_sclr = '1') THEN 
              r_val <= (OTHERS=>'0');
            ELSIF (do_sload = '1') THEN
              r_val <= l_x;
            ELSE
              IF (do_add='1') THEN 
                r_val <= std_logic_vector(a_x_us + b_x_us);
              ELSE 
                r_val <= std_logic_vector(a_x_us - b_x_us);
               END IF;
            END IF;
      END PROCESS;
    END GENERATE;



    vhdl_addsub: IF (OPTIMIZED = OPTIMIZED_OFF OR  FAMILY /= FAMILY_STRATIX) AND LATENCY = 1 GENERATE
      r: PROCESS(clock, reset)
      BEGIN
        IF (reset = '1') THEN
          r_val <= (OTHERS=> '0');
        ELSIF clock'EVENT AND clock = '1' THEN
          IF (trigger = '1') THEN
            IF (do_sclr = '1') THEN 
              r_val <= (OTHERS=>'0');
            ELSIF (do_sload = '1') THEN
              r_val <= l_x;
            ELSE
              IF (do_add='1') THEN 
                r_val <= std_logic_vector(a_x_us + b_x_us);
              ELSE 
                r_val <= std_logic_vector(a_x_us - b_x_us);
              END IF;
            END IF;
          END IF;
        END IF;
      END PROCESS;
    END GENERATE;
 

    wys_addsub: IF OPTIMIZED = OPTIMIZED_ON AND FAMILY = FAMILY_STRATIX AND LATENCY = 1  GENERATE
            l_x_us_gen:  l_x_us <= unsigned(l_x);
    
            addsub : alt_cusp161_addsubcarry
            GENERIC MAP 
            (
                L=>WIDTH+1,
                OPTIMIZED => OPTIMIZED_ON,
                SIMULATION => SIMULATION
            ) 
            PORT MAP 
            (
                clk=>clock, 
                reset=>reset, 
                ena=>trigger, 
                sreset=>do_sclr, 
                sload=>do_sload, 
                loadval_in=>l_x_us, 
                doAddnSub=>do_add, 
                addL_in=>a_x_us, 
                addR_in=>b_x_us, 
                sum_out=>r_val_us
            );
        
        r_val <= std_logic_vector(r_val_us);
    END GENERATE;

  output_q:    q_int <= r_val(WIDTH DOWNTO 1); 
  q_drive:     q <= q_int;    

END ;


