
# ==================================================
# Define global parameters
# ==================================================

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

# ==================================================
# Define Mesh
# ==================================================

[Mesh]
  [./msh]
    type = FileMeshGenerator
    file = "mesh.e"
  [../]
  [./breakmesh]
    input = msh
    type = BreakMeshByBlockGenerator
  [../]
  [./add_side_sets]
    input = breakmesh
    type = SideSetsFromNormalsGenerator
    normals = '0 -1  0 
               0  1  0
               -1 0  0
               1  0  0
               0  0 -1
               0  0  1'
    fixed_normal = true
    new_boundary = 'y0 y1 x0 x1 z0 z1'
  [../]
[]

# ==================================================
# Define Initial Orientations
# ==================================================

[UserObjects]
  [./euler_angle_file]
    type = ElementPropertyReadFile
    nprop = 3
    prop_file_name = "input_orientations.csv"
    read_type = block
    nblock = 50
    use_zero_based_block_indexing = false
  [../]
[]

# ==================================================
# Define Modules
# ==================================================

[Modules]
  [./TensorMechanics]
    [./Master]
      [./all]
        strain = FINITE
        new_system = true
        add_variables = true
        formulation = TOTAL
        volumetric_locking_correction = true # linear hex elements
        generate_output = 'elastic_strain_xx elastic_strain_yy elastic_strain_zz
                           strain_xx strain_yy strain_zz
                           cauchy_stress_xx cauchy_stress_yy cauchy_stress_zz'
      [../]
    [../]
    [./CohesiveZoneMaster]
      [./czm_ik]
        boundary = 'interface'
        strain = FINITE
        generate_output = 'traction_x traction_y traction_z
                           jump_x jump_y jump_z normal_traction
                           tangent_traction normal_jump tangent_jump'
      [../]
    [../]
  [../]
[]

# ==================================================
# Define Variables
# ==================================================

[AuxVariables]

  # Material
  [./a]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./b]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./D]
    family = MONOMIAL
    order = CONSTANT
  [../]

  # For crystal orientations (quaternion)
  [./orientation_q1]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./orientation_q2]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./orientation_q3]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./orientation_q4]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

# ==================================================
# Define Kernels
# ==================================================

[AuxKernels]

  # Material
  [./a]
    type = MaterialRealAux
    boundary = 'interface'
    property = a
    execute_on = 'TIMESTEP_END'
    variable = a
    check_boundary_restricted = false
  [../]
  [./b]
    type = MaterialRealAux
    boundary = 'interface'
    property = b
    execute_on = 'TIMESTEP_END'
    variable = b
    check_boundary_restricted = false
  [../]
  [./D]
    type = MaterialRealAux
    boundary = 'interface'
    property = interface_damage
    execute_on = 'TIMESTEP_END'
    variable = D
    check_boundary_restricted = false
  [../]

  # For crystal orientations (quaternion)
  [q1]
    type = MaterialStdVectorAux
    property = orientation
    index = 0
    variable = orientation_q1
  [../]
  [q2]
    type = MaterialStdVectorAux
    property = orientation
    index = 1
    variable = orientation_q2
  [../]
  [q3]
    type = MaterialStdVectorAux
    property = orientation
    index = 2
    variable = orientation_q3
  [../]
  [q4]
    type = MaterialStdVectorAux
    property = orientation
    index = 3
    variable = orientation_q4
  [../]
[]

# ==================================================
# Apply stress
# ==================================================

[Functions]
  [./applied_load_x]
    type = PiecewiseLinear
    x = '0 0.1 36000000.0'
    y = '0 80 80'
  [../]
  [./applied_load_y]
    type = PiecewiseLinear
    x = '0 0.1 36000000.0'
    y = '0 0 0'
  [../]
  [./applied_load_z]
    type = PiecewiseLinear
    x = '0 0.1 36000000.0'
    y = '0 0 0'
  [../]
[]

# ==================================================
# Constraints
# ==================================================

[Constraints]
  [./x1]
    type = EqualValueBoundaryConstraint
    variable = disp_x
    secondary = 'x1'
    penalty = 1e10 # length dependent
  [../]
  [./y1]
    type = EqualValueBoundaryConstraint
    variable = disp_y
    secondary = 'y1'
    penalty = 1e10 # length dependent
  [../]
  [./z1]
    type = EqualValueBoundaryConstraint
    variable = disp_z
    secondary = 'z1'
    penalty = 1e10 # length dependent
  [../]
[]

# ==================================================
# Boundary Conditions
# ==================================================

[BCs]
  [./x0]
    type = DirichletBC
    variable = disp_x
    boundary = x0
    value = 0.0
  [../]
  [./y0]
    type = DirichletBC
    variable = disp_y
    boundary = y0
    value = 0.0
  [../]
  [./z0]
    type = DirichletBC
    variable = disp_z
    boundary = z0
    value = 0.0
  [../]
  [./x1]
    type = FunctionNeumannBC
    boundary = x1
    function = applied_load_x
    variable = disp_x
  [../]
  [./y1]
    type = FunctionNeumannBC
    boundary = y1
    function = applied_load_y
    variable = disp_y
  [../]
  [./z1]
    type = FunctionNeumannBC
    boundary = z1
    function = applied_load_z
    variable = disp_z
  [../]
[]

# ==================================================
# Define Material
# ==================================================

[Materials]
  [./stress]
    type = NEMLCrystalPlasticity
    database = "material.xml"
    model = "vshai"
    large_kinematics = true
    euler_angle_reader = euler_angle_file
  [../]
  [./ShamNeedleman]
    type = GBCavitation
    boundary = 'interface'
    a0 = 4e-05
    b0 = 0.059
    D_failure = 0.9
  [../]
[]

# ==================================================
# Define Preconditioning
# ==================================================

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

# ==================================================
# Define Postprocessing (History)
# ==================================================

[VectorPostprocessors]
  [./ELMTS]
    type = ElementValueSampler
    variable = 'orientation_q1 orientation_q2 orientation_q3 orientation_q4
                cauchy_stress_xx cauchy_stress_yy cauchy_stress_zz
                strain_xx strain_yy strain_zz
                elastic_strain_xx elastic_strain_yy elastic_strain_zz'
    contains_complete_history = false
    sort_by = id
  [../]
[]

# ==================================================
# Define Postprocessing (Model Average)
# ==================================================

[Postprocessors]

  # Number of elements
  [./nelem]
    type = NumElems
  [../]

  # Number of degrees of freedom
  [./ndof]
    type = NumDOFs
  [../]

  # Size of Timestep
  [./dt]
    type = TimestepSize
  [../]

  # Number of linear iterations
  [./num_lin_it]
    type = NumLinearIterations
  [../]

  # Number of non-linear iterations
  [./num_nonlin_it]
    type = NumNonlinearIterations
  [../]

  # Mean Stress
  [./mCS_xx]
    type = ElementAverageValue
    variable = cauchy_stress_xx
  [../]
  [./mCS_yy]
    type = ElementAverageValue
    variable = cauchy_stress_yy
  [../]
  [./mCS_zz]
    type = ElementAverageValue
    variable = cauchy_stress_zz
  [../]

  # Mean Total Strain
  [./mTE_xx]
    type = ElementAverageValue
    variable = strain_xx
  [../]
  [./mTE_yy]
    type = ElementAverageValue
    variable = strain_yy
  [../]
  [./mTE_zz]
    type = ElementAverageValue
    variable = strain_zz
  [../]

  # Mean Elastic Strain
  [./mEE_xx]
    type = ElementAverageValue
    variable = elastic_strain_xx
  [../]
  [./mEE_yy]
    type = ElementAverageValue
    variable = elastic_strain_yy
  [../]
  [./mEE_zz]
    type = ElementAverageValue
    variable = elastic_strain_zz
  [../]

  # Mean Cavitation Model Variables
  [./ma]
    type = ElementAverageValue
    variable = a
  [../]
  [./mb]
    type = ElementAverageValue
    variable = b
  [../]
  [./mD]
    type = ElementAverageValue
    variable = D
  [../]
[]

# ==================================================
# Define Simulation
# ==================================================

[Executioner]

  # Time-dependent (transient) and multi-physics problem
  type = Transient
  automatic_scaling = false
  
  # Options for PETSc (solving linear equations)
  petsc_options = '-snes_converged_reason -ksp_converged_reason'
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package -ksp_gmres_restart 
                         -pc_hypre_boomeramg_strong_threshold -pc_hypre_boomeramg_interp_type -pc_hypre_boomeramg_coarsen_type 
                         -pc_hypre_boomeramg_agg_nl -pc_hypre_boomeramg_agg_num_paths -pc_hypre_boomeramg_truncfactor'
  petsc_options_value = 'hypre boomeramg 200 0.7 ext+i PMIS 4 2 0.4'

  # Newton-Raphson solver
  solve_type = NEWTON

  # Tolerances on linear solve
  l_max_its = 256
  l_tol = 1e-6

  # Tolerances on non-linear solve
  nl_max_its = 16
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-6
  nl_forced_its = 1
  n_max_nonlinear_pingpong = 1
  line_search = 'none'

  # Time variables
  start_time = 0
  end_time = 36000000.0
  dtmin = 0.0001
  dtmax = 10000000.0

  # Simulation speed up
  # residual_and_jacobian_together = true
  # [./Predictor]
  #   type = SimplePredictor
  #   scale = 1.0
  # [../]

  # Timestep growth
  [./TimeStepper]
    type = IterationAdaptiveDT
    growth_factor = 2
    cutback_factor = 0.5
    linear_iteration_ratio = 1000
    optimal_iterations = 12
    iteration_window = 1
    dt = 0.0001
  [../]
[]

# ==================================================
# Define Simulation Output
# ==================================================

[Outputs]
  print_linear_residuals = false
  perf_graph = true

  # Exodus Output
  [./exodus]
    type = Exodus
    # elemental_as_nodal = true
    interval = 2
  [../]

  # CSV Output
  [./outfile]
    type = CSV
    file_base = 'results'
    delimiter = ','
    time_data = true
    execute_vector_postprocessors_on = timestep_end
  [../]
[]
