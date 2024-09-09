import Mathlib.Tactic.DeriveFintype
import Mathlib.Data.Fintype.Perm
import Mathlib.Data.Fintype.Prod

/-- A Cartesian axis in 3D space. -/
inductive Axis : Type
  /-- The `x` or left-right axis. -/
  | x : Axis
  /-- The `y` or bottom-top axis. -/
  | y : Axis
  /-- The `z` or back-front axis. -/
  | z : Axis

deriving instance DecidableEq, Fintype for Axis

namespace Axis

instance : Repr Axis := ⟨fun e _ ↦ Std.Format.text <| match e with
  | Axis.x => "X"
  | Axis.y => "Y"
  | Axis.z => "Z"
⟩

protected theorem card : Fintype.card Axis = 3 :=
  rfl

/-- Permutes the `x`, `y`, `z` axes in cyclic order. -/
def rotate : Axis → Axis
  | Axis.x => Axis.y
  | Axis.y => Axis.z
  | Axis.z => Axis.x

theorem rotate_ne : ∀ a : Axis, a.rotate ≠ a := by
  decide

@[simp]
theorem rotate_inj : ∀ {a b : Axis}, a.rotate = b.rotate ↔ a = b := by
  decide

/-- Whether `b` is the next axis in cyclic order to `a`. -/
def IsNext (a b : Axis) : Prop :=
  a.rotate = b

instance : DecidableRel IsNext :=
  inferInstanceAs (∀ a b : Axis, Decidable (a.rotate = b))

theorem isNext_irrefl (a : Axis) : ¬ IsNext a a :=
  rotate_ne a

@[simp]
theorem isNext_asymm_iff : ∀ {a b}, a ≠ b → (¬ IsNext a b ↔ IsNext b a) := by
  decide

theorem IsNext.asymm (h : IsNext a b) : ¬ IsNext b a := by
  obtain rfl | hn := eq_or_ne b a
  · exact isNext_irrefl b
  · exact (isNext_asymm_iff hn).2 h

@[simp]
theorem isNext_rotate : ∀ {a b}, IsNext a.rotate b.rotate ↔ IsNext a b := by
  decide

theorem IsNext.congr_left (hb : IsNext a b) (hc : IsNext a c) : b = c :=
  hb.symm.trans hc

theorem IsNext.congr_right (ha : IsNext a c) (hb : IsNext b c) : a = b :=
  rotate_inj.1 <| ha.trans hb.symm

/-- Given two distinct axes, returns the third. If both axes are equal, we just return it. -/
def other : Axis → Axis → Axis
  | Axis.x, Axis.y => Axis.z
  | Axis.x, Axis.z => Axis.y
  | Axis.y, Axis.x => Axis.z
  | Axis.y, Axis.z => Axis.x
  | Axis.z, Axis.x => Axis.y
  | Axis.z, Axis.y => Axis.x
  | Axis.x, Axis.x => Axis.x
  | Axis.y, Axis.y => Axis.y
  | Axis.z, Axis.z => Axis.z

@[simp]
theorem other_self : ∀ a, other a a = a := by
  decide

@[simp]
theorem other_eq_left_iff : ∀ {a b}, other a b = a ↔ a = b := by
  decide

@[simp]
theorem other_eq_right_iff : ∀ {a b}, other a b = b ↔ a = b := by
  decide

theorem other_eq_iff : ∀ {a b c}, a ≠ b → (other a b = c ↔ c ≠ a ∧ c ≠ b) := by
  decide

theorem other_eq (h₁ : a ≠ b) (h₂ : c ≠ a) (h₃ : c ≠ b) : other a b = c :=
  (other_eq_iff h₁).2 ⟨h₂, h₃⟩

theorem other_ne_iff (h : a ≠ b) : other a b ≠ c ↔ c = a ∨ c = b := by
  rw [← not_iff_not, not_ne_iff, other_eq_iff h, not_or]

theorem other_comm : ∀ a b, other a b = other b a := by
  decide

theorem other_ne_left (h : a ≠ b) : other a b ≠ a :=
  ((other_eq_iff h).1 rfl).1

theorem other_ne_right (h : a ≠ b) : other a b ≠ b :=
  ((other_eq_iff h).1 rfl).2

@[simp]
theorem other_other_left : ∀ {a b}, other (other a b) a = b := by
  decide

@[simp]
theorem other_other_right : ∀ {a b}, other (other a b) b = a := by
  decide

@[simp]
theorem other_other_left' : other a (other a b) = b := by
  rw [other_comm, other_other_left]

@[simp]
theorem other_other_right' : other b (other a b) = a := by
  rw [other_comm, other_other_right]

@[simp]
theorem other_inj_left : ∀ {a b c}, other c a = other c b ↔ a = b := by
  decide

@[simp]
theorem other_inj_right : other a c = other b c ↔ a = b := by
  rw [other_comm, @other_comm b, other_inj_left]

@[simp]
theorem other_isNext_left : ∀ {a b}, (other a b).IsNext a ↔ a.IsNext b := by
  decide

@[simp]
theorem other_isNext_right : ∀ {a b}, (other a b).IsNext b ↔ b.IsNext a := by
  decide

@[simp]
theorem isNext_other_left : ∀ {a b}, IsNext a (other a b) ↔ b.IsNext a := by
  decide

@[simp]
theorem isNext_other_right : ∀ {a b}, IsNext b (other a b) ↔ a.IsNext b := by
  decide

end Axis

/-- One of six possible orientations for a face of a Rubik's cube, represented as `Bool × Axis`.

We employ the convention that the sign argument is `true` for the front, right, and up orientations.

This type will also be used for the colors in a Rubik's cube, using the following convention:

* Red = Right
* White = Up
* Green = Front
* Orange = Left
* Yellow = Down
* Blue = Back
-/
def Orientation : Type := Bool × Axis

namespace Orientation

instance decEq : DecidableEq Orientation :=
  inferInstanceAs (DecidableEq (Bool × Axis))

instance : Repr Orientation := ⟨fun e _ ↦ Std.Format.text <| match e with
  | (true, Axis.x) => "R"
  | (true, Axis.y) => "U"
  | (true, Axis.z) => "F"
  | (false, Axis.x) => "L"
  | (false, Axis.y) => "D"
  | (false, Axis.z) => "B"
⟩

/-- The color represented by an orientation, as a Unicode square. -/
def color : Orientation → String
  | (true, Axis.x) => "🟥"
  | (true, Axis.y) => "⬜"
  | (true, Axis.z) => "🟩"
  | (false, Axis.x) => "🟧"
  | (false, Axis.y) => "🟨"
  | (false, Axis.z) => "🟦"

instance : HAppend Std.Format Orientation Std.Format :=
  ⟨fun s a ↦ s ++ a.color⟩

instance instFintype : Fintype Orientation :=
  inferInstanceAs (Fintype (Bool × Axis))

protected theorem card : Fintype.card Orientation = 6 :=
  rfl

/-- Right orientation or red color. -/
def R : Orientation := (true, Axis.x)
/-- Up orientation or white color. -/
def U : Orientation := (true, Axis.y)
/-- Front orientation or green color. -/
def F : Orientation := (true, Axis.z)

/-- Left orientation or orange color. -/
def L : Orientation := (false, Axis.x)
/-- Down orientation or yellow color. -/
def D : Orientation := (false, Axis.y)
/-- Back orientation or blue color. -/
def B : Orientation := (false, Axis.z)

/-- The sign (positive or negative) corresponding to the orientation. -/
def sign (a : Orientation) : Bool :=
  a.1

@[simp]
theorem sign_mk (b : Bool) (a : Axis) : sign (b, a) = b :=
  rfl

/-- The Cartesian axis corresponding to the orientation. -/
def axis (a : Orientation) : Axis :=
  a.2

@[simp]
theorem axis_mk (b : Bool) (a : Axis) : axis (b, a) = a :=
  rfl

@[ext]
theorem ext (h₁ : sign a = sign b) (h₂ : axis a = axis b) : a = b :=
  Prod.ext h₁ h₂

/-- The negative of an orientation. -/
instance : Neg Orientation :=
  ⟨fun a ↦ (!a.1, a.2)⟩

instance : InvolutiveNeg Orientation :=
  ⟨fun _ ↦ ext (Bool.not_not _) rfl⟩

@[simp]
theorem neg_mk (b : Bool) (a : Axis) : instNeg.neg (b, a) = (!b, a) :=
  rfl

@[simp]
theorem sign_neg (a : Orientation) : (-a).sign = !a.sign :=
  rfl

@[simp]
theorem axis_neg (a : Orientation) : (-a).axis = a.axis :=
  rfl

theorem eq_or_neg_of_eq_axis (h : axis a = axis b) : a = b ∨ a = -b := by
  obtain hs | hs := Bool.eq_or_eq_not a.sign b.sign
  · exact Or.inl (ext hs h)
  · exact Or.inr (ext hs h)

/-- Two orientations are adjacent when they have distinct axes. -/
def IsAdjacent (a b : Orientation) : Prop :=
  a.axis ≠ b.axis

instance IsAdjacent.decRel : DecidableRel IsAdjacent :=
  inferInstanceAs (∀ a b : Orientation, Decidable (a.axis ≠ b.axis))

@[simp]
theorem neg_isAdjacent : IsAdjacent (-a) b ↔ IsAdjacent a b :=
  Iff.rfl

@[simp]
theorem isAdjacent_neg : IsAdjacent a (-b) ↔ IsAdjacent a b :=
  Iff.rfl

theorem IsAdjacent.ne (h : IsAdjacent a b) : a ≠ b := by
  rintro rfl
  exact h rfl

theorem isAdjacent_comm : IsAdjacent a b ↔ IsAdjacent b a :=
  ne_comm

alias ⟨IsAdjacent.swap, _⟩ := isAdjacent_comm

/-- Given two adjacent orientations, returns the "cross product", i.e. the orientation `c` adjacent
to both, such that `(a, b, c)` is oriented as the standard basis. -/
def cross (a b : Orientation) : Orientation :=
  ((a.axis.IsNext b.axis) == (a.sign == b.sign), a.axis.other b.axis)

@[simp]
theorem sign_cross (a b : Orientation) :
    (cross a b).sign = ((a.axis.IsNext b.axis) == (a.sign == b.sign)) :=
  rfl

@[simp]
theorem axis_cross (a b : Orientation) : (cross a b).axis = a.axis.other b.axis :=
  rfl

theorem IsAdjacent.cross_left (h : IsAdjacent a b) : IsAdjacent (cross a b) a :=
  Axis.other_ne_left h

theorem IsAdjacent.cross_right (h : IsAdjacent a b) : IsAdjacent (cross a b) b :=
  Axis.other_ne_right h

@[simp]
theorem cross_neg_left : ∀ (a b : Orientation), cross (-a) b = -cross a b := by
  decide

@[simp]
theorem cross_neg_right : ∀ (a b : Orientation), cross a (-b) = -cross a b := by
  decide

theorem cross_asymm : ∀ {a b}, IsAdjacent a b → cross a b = - cross b a := by
  decide

@[simp]
theorem cross_inj_left : ∀ {a b c}, cross a c = cross b c ↔ a = b := by
  decide

@[simp]
theorem cross_inj_right : ∀ {a b c}, cross a b = cross a c ↔ b = c := by
  decide

@[simp]
theorem cross_cross_left : ∀ (a b), cross (cross a b) a = b := by
  decide

@[simp]
theorem cross_cross_right : ∀ (a b), cross b (cross a b) = a := by
  decide

theorem cross_cross_left' (h : IsAdjacent a b) : cross a (cross a b) = -b := by
  rw [cross_asymm h, cross_neg_right, cross_cross_right]

theorem cross_cross_right' (h : IsAdjacent a b) : cross (cross a b) b = -a := by
  rw [cross_asymm h, cross_neg_left, cross_cross_left]

/-- Take a piece with stickers on orientations `a ≠ r`, and perform a **counterclockwise** rotation
in orientation `r`. This function returns the new orientation of the sticker with orientation `a`.

For instance, `rotate U F = L` since performing `F'` sends the upper-front corner to the left-front
one.

The reason this is inverted is so that
`(cube.rotate r).edge a b = Cube.edge (a.rotate r) (b.rotate r)`. -/
def rotate (a r : Orientation) : Orientation :=
  if r.axis = a.axis then a else cross r a

theorem rotate_of_eq {a r : Orientation} (h : r.axis = a.axis) : a.rotate r = a :=
  dif_pos h

theorem rotate_of_ne {a r : Orientation} (h : r.axis ≠ a.axis) : a.rotate r = cross r a :=
  dif_neg h

@[simp]
theorem rotate_neg : rotate (-a) r = -rotate a r := by
  by_cases h : r.axis = a.axis
  · rwa [rotate_of_eq h, rotate_of_eq]
  · rwa [rotate_of_ne h, rotate_of_ne, cross_neg_right]

@[simp]
theorem rotate_inj : ∀ {a b r}, rotate a r = rotate b r ↔ a = b := by
  decide

theorem isAdjacent_rotate : ∀ {a b r : Orientation},
    IsAdjacent (a.rotate r) (b.rotate r) ↔ IsAdjacent a b := by
  decide

theorem IsAdjacent.rotate {a b : Orientation} (h : IsAdjacent a b) (r : Orientation) :
    IsAdjacent (a.rotate r) (b.rotate r) :=
  isAdjacent_rotate.2 h

/-- A predicate for three pairwise adjacent orientations, oriented as the standard basis.

The orientation condition is required, since it's not physically possible to exchange two pieces in
a corner without dissassembling it. -/
@[pp_nodot]
def IsAdjacent₃ (a b c : Orientation) : Prop :=
  IsAdjacent a b ∧ cross a b = c

instance IsAdjacent₃.decRel : ∀ a b c, Decidable (IsAdjacent₃ a b c) :=
  inferInstanceAs (∀ a b c, Decidable (IsAdjacent a b ∧ cross a b = c))

theorem IsAdjacent₃.IsAdjacent (h : IsAdjacent₃ a b c) : IsAdjacent a b :=
  h.1

theorem IsAdjacent.IsAdjacent₃ (h : IsAdjacent a b) : IsAdjacent₃ a b (cross a b) :=
  ⟨h, rfl⟩

theorem IsAdjacent₃.congr (h₁ : IsAdjacent₃ a b c₁) (h₂ : IsAdjacent₃ a b c₂) : c₁ = c₂ :=
  h₁.2.symm.trans h₂.2

theorem isAdjacent₃_cyclic : IsAdjacent₃ a b c ↔ IsAdjacent₃ b c a := by
  constructor <;>
  rintro ⟨h, rfl⟩
  · exact ⟨(h.cross_right).symm, cross_cross_right _ _⟩
  · exact ⟨h.cross_left, cross_cross_left _ _⟩

alias ⟨IsAdjacent₃.cyclic, _⟩ := isAdjacent₃_cyclic

theorem cross_rotate : ∀ {a b r : Orientation},
    IsAdjacent a b → cross (a.rotate r) (b.rotate r) = (cross a b).rotate r := by
  decide

theorem isAdjacent₃_rotate {a b c r : Orientation} :
    IsAdjacent₃ (a.rotate r) (b.rotate r) (c.rotate r) ↔ IsAdjacent₃ a b c := by
  constructor
  · rintro ⟨h, hr⟩
    have H := isAdjacent_rotate.1 h
    rw [cross_rotate H, rotate_inj] at hr
    exact ⟨H, hr⟩
  · rintro ⟨h, rfl⟩
    exact ⟨h.rotate r, cross_rotate h⟩

theorem IsAdjacent₃.rotate {a b c : Orientation} (h : IsAdjacent₃ a b c) (r : Orientation) :
    IsAdjacent₃ (a.rotate r) (b.rotate r) (c.rotate r) :=
  isAdjacent₃_rotate.2 h

end Orientation

open Orientation

/-- An edge piece can be identified with an ordered pair of adjacent orientations. The first
orientation determines the face in which the piece lies, and the second orientation determines its
relative orientation with respect to it. -/
structure EdgePiece : Type where
  /-- The face in which this piece lies. -/
  fst : Orientation
  /-- The relative orientation of the piece with respect to its face. -/
  snd : Orientation
  /-- Both orientations are adjacent. -/
  isAdjacent : IsAdjacent fst snd

deriving instance DecidableEq, Fintype for EdgePiece

/-- Builds an edge piece from adjacent orientations. -/
def Orientation.IsAdjacent.toEdgePiece (h : IsAdjacent a b) : EdgePiece :=
  EdgePiece.mk a b h

namespace EdgePiece

instance : Inhabited EdgePiece :=
  ⟨EdgePiece.mk U L (by decide)⟩

instance : Repr EdgePiece :=
  ⟨fun e ↦ [e.fst, e.snd].repr⟩

protected theorem card : Fintype.card EdgePiece = 24 :=
  rfl

@[ext]
theorem ext {e₁ e₂ : EdgePiece} (hf : e₁.fst = e₂.fst) (hs : e₁.snd = e₂.snd) : e₁ = e₂ := by
  cases e₁
  cases e₂
  simpa using ⟨hf, hs⟩

/-- Constructs the other edge piece sharing an edge. -/
def swap (e : EdgePiece) : EdgePiece :=
  e.isAdjacent.swap.toEdgePiece

end EdgePiece

/-- A corner piece can be identified with an ordered triple of pairwise adjacent orientations,
oriented as the standard basis. The first orientation determines the face in which the piece lies,
and the other two orientations determine its relative orientation with respect to it. -/
structure CornerPiece : Type where
  /-- The face in which this piece lies. -/
  fst : Orientation
  /-- The (first) relative orientation of the piece with respect to its face. -/
  snd : Orientation
  /-- The (second) relative orientation of the piece with respect to its face. This is actually
  completely determined from the other two, but we still define it for symmetry. -/
  thd : Orientation
  /-- All colors are adjacent, and form a positively oriented basis. -/
  isAdjacent₃ : IsAdjacent₃ fst snd thd

deriving instance DecidableEq for CornerPiece

/-- Builds a corner from pairwise isAdjacent orientations. -/
def Orientation.IsAdjacent₃.toCornerPiece (h : IsAdjacent₃ a b c) : CornerPiece :=
  CornerPiece.mk a b c h

@[ext]
theorem CornerPiece.ext {c₁ c₂ : CornerPiece}
    (hf : c₁.fst = c₂.fst) (hs : c₁.snd = c₂.snd) : c₁ = c₂ := by
  obtain ⟨f₁, s₁, t₁, h₁⟩ := c₁
  obtain ⟨f₂, s₂, t₂, h₂⟩ := c₂
  dsimp at *
  subst hf hs
  simpa using h₁.congr h₂

/-- Edge pieces and corner pieces can be put in bijection. -/
def EdgeCornerEquiv : EdgePiece ≃ CornerPiece where
  toFun e := e.isAdjacent.IsAdjacent₃.toCornerPiece
  invFun c := c.isAdjacent₃.IsAdjacent.toEdgePiece
  left_inv _ := rfl
  right_inv c := by ext <;> rfl

namespace CornerPiece

instance : Inhabited CornerPiece :=
  ⟨CornerPiece.mk R U F (by decide)⟩

instance : Repr CornerPiece :=
  ⟨fun c ↦ [c.fst, c.snd, c.thd].repr⟩

instance : Fintype CornerPiece :=
  Fintype.ofEquiv _ EdgeCornerEquiv

protected theorem card : Fintype.card CornerPiece = 24 :=
  rfl

/-- Permutes the colors in a corner cyclically. -/
def cyclic (c : CornerPiece) : CornerPiece :=
  c.isAdjacent₃.cyclic.toCornerPiece

end CornerPiece

/-- A pre-Rubik's cube. We represent this as a permutation of the edge pieces, and a permutation of
the corner pieces, such that pieces in the same edge or corner get mapped to the same edge or
corner.

The returned edges and corners will be oriented in the same order as the passed orientations. For
instance, `cube.edge R F` is some edge `e`, whose right sticker is `e.fst` and whose front sticker
is `e.snd`.

This can be thought as the type of Rubik's cubes that can be assembled, without regard for the
solvability invariants. -/
structure PRubik : Type where
  /-- Returns the edge at a given orientation. -/
  edgeEquiv : EdgePiece ≃ EdgePiece
  /-- Returns the corner at a given orientation. -/
  cornerEquiv : CornerPiece ≃ CornerPiece
  /-- Swapping an edge's orientations results in a swapped edge. -/
  edge_swap (e : EdgePiece) : edgeEquiv e.swap = (edgeEquiv e).swap
  /-- Cyclically permuting a corner's orientations results in a cyclically permuted corner. -/
  corner_cyclic (c : CornerPiece) : cornerEquiv c.cyclic = (cornerEquiv c).cyclic

namespace PRubik

deriving instance DecidableEq, Fintype for PRubik

/-- An auxiliary function to get an edge piece in a cube, inferring the adjacency hypothesis. -/
def edgePiece (cube : PRubik) (a b : Orientation) (h : IsAdjacent a b := by decide) : EdgePiece :=
  cube.edgeEquiv (EdgePiece.mk a b h)

/-- An auxiliary function to get a corner piece in a cube, inferring the adjacency hypothesis. -/
def cornerPiece (cube : PRubik) (a b c : Orientation) (h : IsAdjacent₃ a b c := by decide) :
    CornerPiece :=
  cube.cornerEquiv (CornerPiece.mk a b c h)

@[ext]
theorem ext (cube₁ cube₂ : PRubik)
    (he : ∀ a b (h : IsAdjacent a b), cube₁.edgePiece a b h = cube₂.edgePiece a b h)
    (hc : ∀ a b c (h : IsAdjacent₃ a b c), cube₁.cornerPiece a b c h = cube₂.cornerPiece a b c h) :
    cube₁ = cube₂ := by
  obtain ⟨e₁, c₁, _, _⟩ := cube₁
  obtain ⟨e₂, c₂, _, _⟩ := cube₂
  simp
  rw [Equiv.ext_iff, Equiv.ext_iff]
  exact ⟨fun x ↦ he _ _ x.isAdjacent, fun x ↦ hc _ _ _ x.isAdjacent₃⟩

/-- The edges in a Rubik's cube. This is an auxiliary function for the `Repr` instance. -/
def edgePieces (cube : PRubik) : List EdgePiece :=
  [cube.edgePiece U B, cube.edgePiece U L, cube.edgePiece U R, cube.edgePiece U F,
    cube.edgePiece L B, cube.edgePiece L F, cube.edgePiece F R, cube.edgePiece R B,
    cube.edgePiece D B, cube.edgePiece D L, cube.edgePiece D R, cube.edgePiece D F]

/-- The corners in a Rubik's cube. This is an auxiliary function for the `Repr` instance. -/
def cornerPieces (cube : PRubik) : List CornerPiece :=
  [cube.cornerPiece U B L, cube.cornerPiece U R B, cube.cornerPiece U L F, cube.cornerPiece U F R,
    cube.cornerPiece D L B, cube.cornerPiece D B R, cube.cornerPiece D F L, cube.cornerPiece D R F]

open Std.Format in
instance : Repr PRubik := ⟨fun cube _ ↦
  letI e := cube.edgePieces
  letI c := cube.cornerPieces
  have : e.length = 12 := rfl
  have : c.length = 8 := rfl
  let space := text "⬛⬛⬛"
  -- Up face
  space ++ c[0].fst ++ e[0].fst ++ c[1].fst ++ space ++ line
    ++ space ++ e[1].fst ++ U ++ e[2].fst ++ space ++ line
    ++ space ++ c[2].fst ++ e[3].fst ++ c[3].fst ++ space ++ line
  -- Left, front, and right faces
  ++ c[0].thd ++ e[1].snd ++ c[2].snd ++ c[2].thd ++ e[3].snd ++
    c[3].snd ++ c[3].thd ++ e[2].snd ++ c[1].snd ++ line
  ++ e[4].fst ++ L ++ e[5].fst ++ e[5].snd ++ F ++ e[6].fst ++ e[6].snd ++ R ++ e[7].fst ++ line
  ++ c[4].snd ++ e[9].snd ++ c[6].thd ++ c[6].snd ++ e[11].snd ++
    c[7].thd ++ c[7].snd ++ e[10].snd ++ c[5].thd ++ line
  -- Down face
  ++ space ++ c[6].fst ++ e[11].fst ++ c[7].fst ++ space ++ line
    ++ space ++ e[9].fst ++ D ++ e[10].fst ++ space ++ line
    ++ space ++ c[4].fst ++ e[8].fst ++ c[5].fst ++ space ++ line
  -- Back face
  ++ space ++ c[4].thd ++ e[8].snd ++ c[5].snd ++ space ++ line
    ++ space ++ e[4].snd ++ B ++ e[7].snd ++ space ++ line
    ++ space ++ c[0].snd ++ e[0].snd ++ c[1].thd ++ space⟩

/-- A solved Rubik's cube. -/
def Solved : PRubik where
  edgeEquiv := Equiv.refl _
  cornerEquiv := Equiv.refl _
  edge_swap _ := rfl
  corner_cyclic _ := rfl

instance : Inhabited PRubik :=
  ⟨Solved⟩

#eval Solved

#exit

/-- Applies a clockwise rotation to a Rubik's cube. -/
def rotate (cube : PRubik) (r : Orientation) : PRubik where
  edgeEquiv e := if r = a ∨ r = b
    then cube.edge _ _ (h.rotate r)
    else cube.edge e
  cornerEquiv c := if r = a ∨ r = b ∨ r = c
    then cube.corner _ _ _ (h.rotate r)
    else cube.corner c
  edge_swap h := by
    simp_rw [or_comm]
    split <;>
    rw [cube.edge_swap]
  corner_cyclic := @fun a b c h ↦ by
    simp_rw [@or_rotate (r = a)]
    split <;>
    rw [cube.corner_cyclic]

    #exit

end PRubik

/-- A sequence of moves to be applied to a Rubik's cube. -/
def Moves : Type := List Orientation

namespace Moves

instance : EmptyCollection Moves :=
  inferInstanceAs (EmptyCollection (List Orientation))

instance : Append Moves :=
  inferInstanceAs (Append (List Orientation))

/-- Turn right face. -/
def R : Moves := [Orientation.R]
/-- Turn up face. -/
def U : Moves := [Orientation.U]
/-- Turn front face. -/
def F : Moves := [Orientation.F]

/-- Turn left face. -/
def L : Moves := [Orientation.L]
/-- Turn down face. -/
def D : Moves := [Orientation.D]
/-- Turn back face. -/
def B : Moves := [Orientation.D]

/-- Turn right face twice. -/
def R2 : Moves := R ++ R
/-- Turn up face twice. -/
def U2 : Moves := U ++ U
/-- Turn front face twice. -/
def F2 : Moves := F ++ F

/-- Turn left face twice. -/
def L2 : Moves := L ++ L
/-- Turn down face twice. -/
def D2 : Moves := D ++ D
/-- Turn back face twice. -/
def B2 : Moves := B ++ B

/-- Turn right face backwards. -/
def R' : Moves := R2 ++ R
/-- Turn up face backwards. -/
def U' : Moves := U2 ++ U
/-- Turn front face backwards. -/
def F' : Moves := F2 ++ F

/-- Turn left face backwards. -/
def L' : Moves := L2 ++ L
/-- Turn down face backwards. -/
def D' : Moves := D2 ++ D
/-- Turn back face backwards. -/
def B' : Moves := B2 ++ B

end Moves

namespace Rubik

/-- Applies a sequence of moves to a Rubik's cube. -/
def Move (cube : Rubik) (m : Moves) : Rubik :=
  m.foldl Rubik.rotate cube

theorem move_append (cube : Rubik) (m n : Moves) : cube.Move (m ++ n) = (cube.Move m).Move n :=
  List.foldl_append _ _ _ _

end Rubik

instance Moves.instSetoid : Setoid Moves where
  r m n := Rubik.Solved.Move m = Rubik.Solved.Move n
  iseqv := by
    constructor
    exacts [fun _ ↦ rfl, Eq.symm, Eq.trans]

/-- The Rubik's cube group is defined as the set of possible move sequences up to equivalence. -/
def RubikGroup : Type := Quotient Moves.instSetoid

instance : Group RubikGroup where
  mul a b := by
    refine Quotient.lift₂ (fun m n ↦ ⟦m ++ n⟧) ?_ a b
    intro m₁ m₂ n₁ n₂ hm hn
    apply Quotient.sound
    change _ = _ at *
    rw [Rubik.move_append, Rubik.move_append, hm, hn]


/-#eval Rubik.Solved.Move [U, R, R, F, B, R, B, B, R, U, U, L, B, B, R, U, U, U, D, D, D, R, R,
  F, R, R, R, L, B, B, U, U, F, F]-/
