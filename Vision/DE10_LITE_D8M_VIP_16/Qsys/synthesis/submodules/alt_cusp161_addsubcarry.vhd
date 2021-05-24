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

--
-- addsub unit that codes the carry/borrow condition in bottom two bits
--
--
LIBRARY IEEE, ALTERA, STRATIX;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

 -- synopsys synthesis_off
USE STRATIX.all;
USE STRATIX.stratix_components.ALL;
 -- synopsys synthesis_on
 
USE altera.ALT_CUSP161_PACKAGE.ALL;

ENTITY alt_cusp161_asc_carrypropagator IS
PORT (
  cin     : IN  STD_LOGIC;
  cout    : OUT STD_LOGIC;
  inverta : IN STD_LOGIC
);
END;

ARCHITECTURE WYSI OF alt_cusp161_asc_carrypropagator IS
  COMPONENT stratix_lcell
  GENERIC (
    operation_mode    : string := "normal";
    synch_mode : string := "off";
    register_cascade_mode   : string := "off";
    sum_lutc_input : string := "datac";
    lut_mask       : string := "ffff";
    power_up : string := "low";
    cin0_used       : string := "false";
    cin1_used       : string := "false";
    cin_used       : string := "false";
    output_mode       : string := "comb_only";
    lpm_type : string := "stratix_lcell"
  );
  PORT (
    -- synopsys synthesis_off
    devclrn : in std_logic := '1';
    devpor  : in std_logic := '1';
    -- synopsys synthesis_on
    clk     : in std_logic := '0';
    dataa     : in std_logic := '1';
    datab     : in std_logic := '1';
    datac     : in std_logic := '1';
    datad     : in std_logic := '1';
    aclr    : in std_logic := '0';
    aload    : in std_logic := '0';
    sclr : in std_logic := '0';
    sload : in std_logic := '0';
    ena : in std_logic := '1';
    cin   : in std_logic := '0';
    cin0   : in std_logic := '0';
    cin1   : in std_logic := '1';
    inverta     : in std_logic := '0';
    regcascin     : in std_logic := '0';
    combout   : out std_logic;
    regout    : out std_logic;
    cout  : out std_logic;
    cout0  : out std_logic;
    cout1  : out std_logic
  );
  END COMPONENT;
  
BEGIN
  carry_propagating_lcell : stratix_lcell
  ----------------------------------
  -- Function is: cout = cin, sum = 0
  ----------------------------------
  -- D C B A  Z
  ----------------------------------
  -- 0 0 0 0  0 THIS HALF USED FOR CARRY
  -- 0 0 0 1  0
  -- 0 0 1 0  0
  -- 0 0 1 1  0
  -- 0 1 0 0  1
  -- 0 1 0 1  1
  -- 0 1 1 0  1
  -- 0 1 1 1  1 => F0 (LOW BYTE)
  ----------
  -- 1 0 0 0  0 THIS HALF USED FOR SUM
  -- 1 0 0 1  0
  -- 1 0 1 0  0
  -- 1 0 1 1  0
  -- 1 1 0 0  0
  -- 1 1 0 1  0
  -- 1 1 1 0  0
  -- 1 1 1 1  0 => 00 (HIGH BYTE)
  ----------------------------------
  GENERIC MAP (
    operation_mode => "arithmetic",
    synch_mode => "off",
    register_cascade_mode => "off",
    sum_lutc_input => "cin",
    lut_mask => "00F0",
    power_up => "low",
    cin0_used => "true",
    cin1_used => "true",
    cin_used => "true",
    output_mode => "comb_only"
  )
  PORT MAP (
    cin => cin,
    cout => cout,
    inverta => inverta
  );  
END ARCHITECTURE WYSI;


LIBRARY IEEE, ALTERA, STRATIX;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE altera.ALT_CUSP161_PACKAGE.ALL;

 -- synopsys synthesis_off
USE STRATIX.all;
USE STRATIX.stratix_components.ALL;
 -- synopsys synthesis_on

ENTITY alt_cusp161_addsubcarry IS
GENERIC (
        SIMULATION   : INTEGER := SIMULATION_OFF;
        OPTIMIZED    : INTEGER := OPTIMIZED_ON;
        FAMILY       : INTEGER := FAMILY_STRATIX;
  L : INTEGER
);
PORT (
  clk, reset : IN STD_LOGIC;
  ena : IN STD_LOGIC := '1';
  sreset : IN STD_LOGIC := '0';
  sload : IN STD_LOGIC;
  loadval_in : IN UNSIGNED(L-1 DOWNTO 0);
  doAddnSub : IN STD_LOGIC := '1';
  addL_in : IN UNSIGNED(L-1 DOWNTO 0);
  addR_in : IN UNSIGNED(L-1 DOWNTO 0);
  sum_out : OUT UNSIGNED(L-1 DOWNTO 0)
);
END;


ARCHITECTURE RTL OF alt_cusp161_addsubcarry IS

  SIGNAL InvertedAddnSub : STD_LOGIC;
  SIGNAL CarryChain : STD_LOGIC_VECTOR(L-1 DOWNTO 0);
  SIGNAL Padding : STD_LOGIC_VECTOR(L/4+1 DOWNTO 0);
  
  COMPONENT alt_cusp161_asc_carrypropagator IS
    PORT (cin     : IN  STD_LOGIC;
        cout    : OUT STD_LOGIC;
        inverta : IN STD_LOGIC);
  END COMPONENT;

  COMPONENT stratix_lcell
  GENERIC (
    operation_mode    : string := "normal";
    synch_mode : string := "off";
    register_cascade_mode   : string := "off";
    sum_lutc_input : string := "datac";
    lut_mask       : string := "ffff";
    power_up : string := "low";
    cin0_used       : string := "false";
    cin1_used       : string := "false";
    cin_used       : string := "false";
    output_mode       : string := "comb_only";
    lpm_type : string := "stratix_lcell"
  );
  PORT (
    -- synopsys synthesis_off
    devclrn : in std_logic := '1';
    devpor  : in std_logic := '1';
    -- synopsys synthesis_on
    clk     : in std_logic := '0';
    dataa     : in std_logic := '1';
    datab     : in std_logic := '1';
    datac     : in std_logic := '1';
    datad     : in std_logic := '1';
    aclr    : in std_logic := '0';
    aload    : in std_logic := '0';
    sclr : in std_logic := '0';
    sload : in std_logic := '0';
    ena : in std_logic := '1';
    cin   : in std_logic := '0';
    cin0   : in std_logic := '0';
    cin1   : in std_logic := '1';
    inverta     : in std_logic := '0';
    regcascin     : in std_logic := '0';
    combout   : out std_logic;
    regout    : out std_logic;
    cout  : out std_logic;
    cout0  : out std_logic;
    cout1  : out std_logic
  );
  END COMPONENT;

BEGIN

  noopt_gen :
  IF (OPTIMIZED = OPTIMIZED_OFF) GENERATE
    PROCESS (clk, reset)
    BEGIN
      IF (reset = '1') THEN
        sum_out <= (others => '0');
      ELSIF (clk'EVENT AND clk = '1') THEN
        IF (ena = '1') THEN
          IF (sreset = '1') THEN
            sum_out <= (others => '0');
          ELSIF (sload = '1') THEN
            sum_out <= loadval_in;
          ELSE        
            IF (doAddnSub = '1') THEN
              sum_out <= addL_in + addR_in;
            ELSE
              sum_out <= ( addL_in(addL_in'high downto 1) & not(addL_in(0)) ) - addR_in;
            END IF;
          END IF;
        END IF;
      END IF;
    END PROCESS;
  END GENERATE;

  opt_gen :
  IF (OPTIMIZED = OPTIMIZED_ON) GENERATE
    InvertedAddnSub <= not doAddnSub;
    ----------------------------------
    -- Ordinary adding lcell
    ----------------------------------
    -- D C B A  Z
    ----------------------------------
    -- 0 0 0 0  0 THIS HALF USED FOR CARRY
    -- 0 0 0 1  0
    -- 0 0 1 0  0
    -- 0 0 1 1  1
    -- 0 1 0 0  1
    -- 0 1 0 1  1
    -- 0 1 1 0  0
    -- 0 1 1 1  1 => B8 (LOW BYTE)
    ----------
    -- 1 0 0 0  0 THIS HALF USED FOR SUM
    -- 1 0 0 1  1
    -- 1 0 1 0  1
    -- 1 0 1 1  0
    -- 1 1 0 0  1
    -- 1 1 0 1  0
    -- 1 1 1 0  0
    -- 1 1 1 1  1 => 96 (HIGH BYTE)
    ----------------------------------
    first_lcell_in_carry_chain : stratix_lcell
    GENERIC MAP (
      operation_mode => "arithmetic",
      synch_mode => "on",
      register_cascade_mode => "off",
      sum_lutc_input => "cin",
      lut_mask => "96B8",
      power_up => "low",
      cin0_used => "false",
      cin1_used => "false",
      cin_used => "false",
      output_mode => "reg_only"
    )
    PORT MAP (
      clk => clk,
      aclr => reset,
      ena => ena,
      sclr => sreset,
      sload => sload,
      dataa => addR_in(0), 
      datab => addL_in(0),
      datac => loadval_in(0),
      regout => sum_out(0),
      inverta => InvertedAddnSub,
      cout => CarryChain(0)
    );
       
    
    addwithsload_per_bit_generate :
    FOR i IN 1 TO L-2 GENERATE
      unpadded_bit :
      IF (i MOD 9) /= 8 GENERATE
        main_wysi : stratix_lcell
        GENERIC MAP (
          operation_mode => "arithmetic",
          synch_mode => "on",
          register_cascade_mode => "off",
          sum_lutc_input => "cin",
          lut_mask => "96E8",
          power_up => "low",
          cin0_used => "true",
          cin1_used => "true",
          cin_used => "true",
          output_mode => "reg_only"
        )
        PORT MAP (
          clk => clk,
          aclr => reset,
          ena => ena,
          sclr => sreset,
          sload => sload,
          dataa => addR_in(i), 
          datab => addL_in(i),
          datac => loadval_in(i),
          cin => CarryChain(i-1),
          cout => CarryChain(i),
          inverta => InvertedAddnSub,
          regout => sum_out(i)
        );
      END GENERATE;
      padded_bit :
      IF (i MOD 9) = 8 GENERATE
        cp1 : alt_cusp161_asc_carrypropagator
        	PORT MAP (cin => CarryChain(i-1), cout => Padding(i/4-1), inverta => InvertedAddnSub);
        cp2 : alt_cusp161_asc_carrypropagator
        	PORT MAP (cin => Padding(i/4-1), cout => Padding(i/4), inverta => InvertedAddnSub);
        main_wysi : stratix_lcell
        GENERIC MAP (
          operation_mode => "arithmetic",
          synch_mode => "on",
          register_cascade_mode => "off",
          sum_lutc_input => "cin",
          lut_mask => "96E8",
          power_up => "low",
          cin0_used => "true",
          cin1_used => "true",
          cin_used => "true",
          output_mode => "reg_only"
        )
        PORT MAP (
          clk => clk,
          aclr => reset,
          ena => ena,
          sclr => sreset,
          sload => sload,
          dataa => addR_in(i), 
          datab => addL_in(i),
          datac => loadval_in(i),
          cin => Padding(i/4),
          cout => CarryChain(i),
          inverta => InvertedAddnSub,
          regout => sum_out(i)
        );
      END GENERATE;
    END GENERATE;
    addwithsload_topbit : stratix_lcell
    ----------------------------------
    -- Calculate sum irrespective of D input
    ----------------------------------
    -- D C B A  Z
    ----------------------------------
    -- 0 0 0 0  0
    -- 0 0 0 1  1
    -- 0 0 1 0  1
    -- 0 0 1 1  0
    -- 0 1 0 0  1
    -- 0 1 0 1  0
    -- 0 1 1 0  0
    -- 0 1 1 1  1
    ----------
    -- 1 0 0 0  0
    -- 1 0 0 1  1
    -- 1 0 1 0  1
    -- 1 0 1 1  0
    -- 1 1 0 0  1
    -- 1 1 0 1  0
    -- 1 1 1 0  0
    -- 1 1 1 1  1 => 9696
    ----------------------------------
    GENERIC MAP (
      operation_mode => "normal",
      synch_mode => "on",
      register_cascade_mode => "off",
      sum_lutc_input => "cin",
      lut_mask => "9696",
      power_up => "low",
      cin0_used => "true",
      cin1_used => "true",
      cin_used => "true",
      output_mode => "reg_only"
    )
    PORT MAP (
      clk => clk,
      aclr => reset,
      ena => ena,
      sclr => sreset,
      sload => sload,
      dataa => addR_in(L-1), 
      datab => addL_in(L-1),
      datac => loadval_in(L-1),
      cin => CarryChain(L-2),
      inverta => InvertedAddnSub,
      regout => sum_out(L-1)
    );
  END GENERATE;
      
END RTL;
