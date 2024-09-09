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

theorem IsAdjacent₃.isAdjacent (h : IsAdjacent₃ a b c) : IsAdjacent a b :=
  h.1

theorem IsAdjacent.isAdjacent₃ (h : IsAdjacent a b) : IsAdjacent₃ a b (cross a b) :=
  ⟨h, rfl⟩

theorem IsAdjacent₃.congr (h₁ : IsAdjacent₃ a b c₁) (h₂ : IsAdjacent₃ a b c₂) : c₁ = c₂ :=
  h₁.2.symm.trans h₂.2

theorem isAdjacent₃_cyclic : IsAdjacent₃ a b c ↔ IsAdjacent₃ b c a := by
  constructor <;>
  rintro ⟨h, rfl⟩
  · exact ⟨(h.cross_right).symm, cross_cross_right _ _⟩
  · exact ⟨h.cross_left, cross_cross_left _ _⟩

alias ⟨IsAdjacent₃.cyclic, _⟩ := isAdjacent₃_cyclic

theorem IsAdjacent₃.ne (h : IsAdjacent₃ a b c) : a ≠ b ∧ b ≠ c ∧ c ≠ a :=
  ⟨h.isAdjacent.ne, h.cyclic.isAdjacent.ne, h.cyclic.cyclic.isAdjacent.ne⟩

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

/-- An edge piece is an ordered pair of adjacent orientations.

Since we identify colors and orientations, there's two possible ways to think of this type:

- The position of an edge piece within a Rubik's cube, specified by its face, followed by its
  relative orientation with respect to it. For instance, `EdgePiece.mk U B _` is the upper piece in the upper-back edge.
- An edge piece with a particular color, within a particular edge. For instance,
  `EdgePiece.mk U B _` is the white piece of the white-blue edge.

The type `PRubik` contains an `EdgePiece ≃ EdgePiece` field, which assigns to each position in the
cube a particular sticker color. -/
structure EdgePiece : Type where
  /-- The first and "distinguished" orientation in the edge piece. -/
  fst : Orientation
  /-- The second orientation in the edge piece. -/
  snd : Orientation
  /-- Both orientations are adjacent. -/
  isAdjacent : IsAdjacent fst snd

deriving instance DecidableEq, Fintype for EdgePiece

namespace EdgePiece

instance : Inhabited EdgePiece :=
  ⟨EdgePiece.mk U B (by decide)⟩

instance : Repr EdgePiece :=
  ⟨fun e ↦ [e.fst, e.snd].repr⟩

protected theorem card : Fintype.card EdgePiece = 24 :=
  rfl

@[ext]
theorem ext {e₁ e₂ : EdgePiece} (hf : e₁.fst = e₂.fst) (hs : e₁.snd = e₂.snd) : e₁ = e₂ := by
  cases e₁
  cases e₂
  simpa using ⟨hf, hs⟩

/-- Builds an `EdgePiece`, automatically inferring the adjacency condition. -/
protected def mk' (a b : Orientation) (h : IsAdjacent a b := by decide) : EdgePiece :=
  EdgePiece.mk a b h

/-- Constructs the other edge piece sharing an edge. -/
def swap (e : EdgePiece) : EdgePiece :=
  ⟨_, _, e.isAdjacent.swap⟩

@[simp]
theorem swap_mk (h : IsAdjacent a b) : swap ⟨a, b, h⟩ = ⟨b, a, h.swap⟩ :=
  rfl

@[simp]
theorem swap_fst (e : EdgePiece) : e.swap.fst = e.snd :=
  rfl

@[simp]
theorem swap_snd (e : EdgePiece) : e.swap.snd = e.fst :=
  rfl

/-- Constructs the finset containing the edge's orientations. -/
def toFinset (e : EdgePiece) : Finset Orientation :=
  ⟨{e.fst, e.snd}, by simpa using e.isAdjacent.ne⟩

theorem card_toFinset (e : EdgePiece) : e.toFinset.card = 2 :=
  rfl

@[simp]
theorem swap_toFinset (e : EdgePiece) : e.swap.toFinset = e.toFinset := by
  rw [toFinset]
  simp_rw [Multiset.pair_comm]
  rfl

instance : Setoid EdgePiece where
  r e₁ e₂ := e₁.toFinset = e₂.toFinset
  iseqv := by
    constructor
    · exact fun x ↦ rfl
    · exact Eq.symm
    · exact Eq.trans

instance : DecidableRel (α := EdgePiece) (· ≈ ·) :=
  fun e₁ e₂ ↦ inferInstanceAs (Decidable (e₁.toFinset = e₂.toFinset))

end EdgePiece

/-- An edge is the equivalence class of edge pieces sharing an edge. -/
def Edge : Type := Quotient EdgePiece.instSetoid

namespace Edge

@[simp]
theorem mk_swap (e : EdgePiece) : (⟦e.swap⟧ : Edge) = ⟦e⟧ :=
  Quotient.sound e.swap_toFinset

instance : Fintype Edge :=
  Quotient.fintype _

protected theorem card : Fintype.card Edge = 12 :=
  rfl

end Edge

/-- A corner piece is an ordered triple of pairwise adjacent orientations, oriented as the standard
basis.

Since we identify colors and orientations, there's two possible ways to think of this type:

- The position of a corner piece within a Rubik's cube, specified by its face, followed by its
  relative orientation with respect to it. For instance, `EdgePiece.mk U B L _` is the upper piece
  in the upper-back-left corner.
- A corner piece with a particular color, within a particular corner. For instance,
  `EdgePiece.mk U B L _` is the white piece of the white-blue-orange edge.

The type `PRubik` contains an `CornerPiece ≃ CornerPiece` field, which assigns to each position in
the cube a particular sticker color. -/
structure CornerPiece : Type where
  /-- The first and "distinguished" orientation in the corner piece. -/
  fst : Orientation
  /-- The second orientation in the corner piece. -/
  snd : Orientation
  /-- The third orientation in the corner piece. This is actually completely determined from the
  other two, but we still define it for symmetry. -/
  thd : Orientation
  /-- All orientations are adjacent, and form a positively oriented basis. -/
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
  toFun e := ⟨_, _, _, e.isAdjacent.isAdjacent₃⟩
  invFun c := ⟨_, _, c.isAdjacent₃.isAdjacent⟩
  left_inv _ := rfl
  right_inv c := by ext <;> rfl

namespace CornerPiece

instance : Inhabited CornerPiece :=
  ⟨CornerPiece.mk U B L (by decide)⟩

instance : Repr CornerPiece :=
  ⟨fun c ↦ [c.fst, c.snd, c.thd].repr⟩

instance : Fintype CornerPiece :=
  Fintype.ofEquiv _ EdgeCornerEquiv

protected theorem card : Fintype.card CornerPiece = 24 :=
  rfl

/-- Permutes the colors in a corner cyclically. -/
def cyclic (c : CornerPiece) : CornerPiece :=
  c.isAdjacent₃.cyclic.toCornerPiece

@[simp]
theorem cyclic_mk (h : IsAdjacent₃ a b c) : cyclic ⟨a, b, c, h⟩ = ⟨b, c, a, h.cyclic⟩ :=
  rfl

@[simp]
theorem cyclic_fst (c : CornerPiece) : c.cyclic.fst = c.snd :=
  rfl

@[simp]
theorem cyclic_snd (c : CornerPiece) : c.cyclic.snd = c.thd :=
  rfl

@[simp]
theorem cyclic_thd (c : CornerPiece) : c.cyclic.thd = c.fst :=
  rfl

/-- Constructs the finset containing the corner's orientations. -/
def toFinset (e : CornerPiece) : Finset Orientation :=
  ⟨{e.fst, e.snd, e.thd}, by
    obtain ⟨h₁, h₂, h₃⟩ := e.isAdjacent₃.ne
    simpa using ⟨⟨h₁, h₃.symm⟩, h₂⟩⟩

theorem card_toFinset (c : CornerPiece) : c.toFinset.card = 3 :=
  rfl

@[simp]
theorem cyclic_toFinset (c : CornerPiece) : c.cyclic.toFinset = c.toFinset := by
  have : ∀ a b c : Orientation, ({a, b, c} : Multiset _) = {c, a, b} := by
    decide
  simp_rw [toFinset, cyclic, IsAdjacent₃.toCornerPiece, this]

instance : Setoid CornerPiece where
  r c₁ c₂ := c₁.toFinset = c₂.toFinset
  iseqv := by
    constructor
    · exact fun x ↦ rfl
    · exact Eq.symm
    · exact Eq.trans

instance : DecidableRel (α := CornerPiece) (· ≈ ·) :=
  fun c₁ c₂ ↦ inferInstanceAs (Decidable (c₁.toFinset = c₂.toFinset))

end CornerPiece

/-- A corner is the equivalence class of corner pieces sharing a corner. -/
def Corner : Type := Quotient CornerPiece.instSetoid

namespace Corner

@[simp]
theorem mk_cyclic (c : CornerPiece) : (⟦c.cyclic⟧ : Corner) = ⟦c⟧ :=
  Quotient.sound c.cyclic_toFinset

instance : Fintype Corner :=
  Quotient.fintype _

protected theorem card : Fintype.card Corner = 8 :=
  rfl

end Corner

/-- A pre-Rubik's cube. We represent this as a permutation of the edge pieces, and a permutation of
the corner pieces, such that pieces in the same edge or corner get mapped to the same edge or
corner.

This can be thought as the type of Rubik's cubes that can be physically assembled, without regard
for the solvability invariants. -/
structure PRubik : Type where
  /-- Returns the edge piece at a given location. -/
  edgePieceEquiv : EdgePiece ≃ EdgePiece
  /-- Returns the corner piece at a given location. -/
  cornerPieceEquiv : CornerPiece ≃ CornerPiece
  /-- Pieces in the same edge get mapped to pieces in the same edge. -/
  edge_swap (e : EdgePiece) : edgePieceEquiv e.swap = (edgePieceEquiv e).swap
  /-- Pieces in the same corner get mapped to pieces in the same corner. -/
  corner_cyclic (c : CornerPiece) : cornerPieceEquiv c.cyclic = (cornerPieceEquiv c).cyclic

attribute [simp] PRubik.edge_swap PRubik.corner_cyclic

namespace PRubik

deriving instance DecidableEq, Fintype for PRubik

@[ext]
theorem ext (cube₁ cube₂ : PRubik)
    (he : ∀ e, cube₁.edgePieceEquiv e = cube₂.edgePieceEquiv e)
    (hc : ∀ c, cube₁.cornerPieceEquiv c = cube₂.cornerPieceEquiv c) :
    cube₁ = cube₂ := by
  obtain ⟨e₁, c₁, _, _⟩ := cube₁
  obtain ⟨e₂, c₂, _, _⟩ := cube₂
  simp
  rw [Equiv.ext_iff, Equiv.ext_iff]
  exact ⟨he, hc⟩

/-- An auxiliary function to get an edge piece in a cube, inferring the adjacency hypothesis. -/
def edgePiece (cube : PRubik) (a b : Orientation) (h : IsAdjacent a b := by decide) : EdgePiece :=
  cube.edgePieceEquiv (EdgePiece.mk a b h)

/-- An auxiliary function to get a corner piece in a cube, inferring the adjacency hypothesis. -/
def cornerPiece (cube : PRubik) (a b c : Orientation) (h : IsAdjacent₃ a b c := by decide) :
    CornerPiece :=
  cube.cornerPieceEquiv (CornerPiece.mk a b c h)

/-- A list with all non-equivalent edges. This is an auxiliary function for the `PRubik.Repr` instance. -/
private def edges : List EdgePiece :=
  [EdgePiece.mk' U B, EdgePiece.mk' U L, EdgePiece.mk' U R, EdgePiece.mk' U F,
    EdgePiece.mk' L B, EdgePiece.mk' L F, EdgePiece.mk' F R, EdgePiece.mk' R B,
    EdgePiece.mk' D B, EdgePiece.mk' D L, EdgePiece.mk' D R, EdgePiece.mk' D F]

/-- The corners in a Rubik's cube. This is an auxiliary function for the `Repr` instance. -/
private def corners (cube : PRubik) : List CornerPiece :=
  [cube.cornerPiece U B L, cube.cornerPiece U R B, cube.cornerPiece U L F, cube.cornerPiece U F R,
    cube.cornerPiece D L B, cube.cornerPiece D B R, cube.cornerPiece D F L, cube.cornerPiece D R F]

open Std.Format in
instance : Repr PRubik := ⟨fun cube _ ↦
  let e := edges.map cube.edgePieceEquiv
  let c := cube.corners
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
@[simps]
protected def id : PRubik where
  edgePieceEquiv := Equiv.refl _
  cornerPieceEquiv := Equiv.refl _
  edge_swap _ := rfl
  corner_cyclic _ := rfl

instance : Inhabited PRubik := ⟨PRubik.id⟩

/-- The composition of two Rubik's cubes is the Rubik's cube where the second's scramble is
performed after the first's.

Note that this is opposite to the usual convention for function composition. -/
@[simps]
protected def trans (cube₁ cube₂ : PRubik) : PRubik where
  edgePieceEquiv := cube₂.edgePieceEquiv.trans cube₁.edgePieceEquiv
  cornerPieceEquiv := cube₂.cornerPieceEquiv.trans cube₁.cornerPieceEquiv
  edge_swap _ := by
    dsimp
    rw [cube₂.edge_swap, cube₁.edge_swap]
  corner_cyclic _ := by
    dsimp
    rw [cube₂.corner_cyclic, cube₁.corner_cyclic]

@[simp]
theorem id_trans (cube : PRubik) : PRubik.id.trans cube = cube := by
  apply PRubik.ext <;>
  intros <;>
  rfl

@[simp]
theorem trans_id (cube : PRubik) : cube.trans PRubik.id = cube := by
  apply PRubik.ext <;>
  intros <;>
  rfl

theorem trans_assoc (cube₁ cube₂ cube₃ : PRubik) :
    (cube₁.trans cube₂).trans cube₃ = cube₁.trans (cube₂.trans cube₃) := by
  apply PRubik.ext <;>
  intros <;>
  rfl

/-- The inverse of a Rubik's cube is obtained -/
@[simps]
protected def symm (cube : PRubik) : PRubik where
  edgePieceEquiv := cube.edgePieceEquiv.symm
  cornerPieceEquiv := cube.cornerPieceEquiv.symm
  edge_swap e := by
    conv_rhs => rw [← cube.edgePieceEquiv.symm_apply_apply (EdgePiece.swap _)]
    rw [cube.edge_swap, Equiv.apply_symm_apply]
  corner_cyclic e := by
    conv_rhs => rw [← cube.cornerPieceEquiv.symm_apply_apply (CornerPiece.cyclic _)]
    rw [cube.corner_cyclic, Equiv.apply_symm_apply]

@[simp]
theorem trans_symm (cube : PRubik) : cube.trans cube.symm = PRubik.id := by
  apply PRubik.ext <;>
  intros <;>
  simp

@[simp]
theorem symm_trans (cube : PRubik) : cube.symm.trans cube = PRubik.id := by
  apply PRubik.ext <;>
  intros <;>
  simp

/-- The "pre-Rubik's cube" group. This isn't the true Rubik's cube group as it contains positions
that are unreachable by valid moves. -/
instance : Group PRubik where
  one := PRubik.id
  mul := PRubik.trans
  mul_assoc := trans_assoc
  one_mul := id_trans
  mul_one := trans_id
  inv := PRubik.symm
  inv_mul_cancel := symm_trans

/-- Applies a **counterclockwise** rotation to an edge piece. -/
private def rotate_edgePiece (r : Orientation) : EdgePiece → EdgePiece :=
  fun e ↦ if r ∈ e.toFinset then ⟨_, _, e.isAdjacent.rotate r⟩ else e

theorem rotate_edgePiece₄ : ∀ r : Orientation, (rotate_edgePiece r)^[4] = id := by
  decide

/-- Applies a **counterclockwise** rotation to a corner piece. -/
private def rotate_cornerPiece (r : Orientation) : CornerPiece → CornerPiece :=
  fun c ↦ if r ∈ c.toFinset then ⟨_, _, _, c.isAdjacent₃.rotate r⟩ else c

theorem rotate_cornerPiece₄ : ∀ r : Orientation, (rotate_cornerPiece r)^[4] = id := by
  decide

/-- Defines the Rubik's cube where only a single **clockwise** move in a given orientation is
performed. -/
def ofOrientation (r : Orientation) : PRubik where
  edgePieceEquiv := ⟨
      rotate_edgePiece r,
      (rotate_edgePiece r)^[3],
      funext_iff.1 (rotate_edgePiece₄ r),
      funext_iff.1 (rotate_edgePiece₄ r)⟩
  cornerPieceEquiv := ⟨
      rotate_cornerPiece r,
      (rotate_cornerPiece r)^[3],
      funext_iff.1 (rotate_cornerPiece₄ r),
      funext_iff.1 (rotate_cornerPiece₄ r)⟩
  edge_swap e := by
    dsimp
    simp_rw [rotate_edgePiece, EdgePiece.swap_toFinset]
    split <;>
    rfl
  corner_cyclic c := by
    dsimp
    simp_rw [rotate_cornerPiece, CornerPiece.cyclic_toFinset]
    split <;>
    rfl

/-- Applies a clockwise rotation to a Rubik's cube. -/
def rotate (cube : PRubik) (r : Orientation) : PRubik :=
  cube.trans (ofOrientation r)

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

namespace PRubik

/-- Applies a sequence of moves to a Rubik's cube. -/
def move (cube : PRubik) (m : Moves) : PRubik :=
  m.foldl PRubik.rotate cube

theorem move_append (cube : PRubik) (m n : Moves) : cube.move (m ++ n) = (cube.move m).move n :=
  List.foldl_append _ _ _ _

end PRubik

#eval PRubik.id.move [U, R, R, F, B, R, B, B, R, U, U, L, B, B, R, U, U, U, D, D, D, R, R,
  F, R, R, R, L, B, B, U, U, F, F]
