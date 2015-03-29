
#include <gtk/gtk.h>

/* INCLUDES FROM gdk/gdk.c */
/* pod #include <config.h> */

#include <string.h>
#include <stdlib.h>

#include "gdk.h"
#include "gdkinternals.h"
#include "gdkintl.h"

#ifndef HAVE_XCONVERTCASE
#include "gdkkeysyms.h"
#endif
#include "gdkalias.h"

/* Private variable declarations
 */
static int gdk_initialized = 0;			    /* 1 if the library is initialized,
						     * 0 otherwise.
						     */
/* FROM gdkglobals.c */
gchar              *_gdk_display_name = NULL;
gint                _gdk_screen_number = -1;
gchar              *_gdk_display_arg_name = NULL;


/* END INCLUDES FROM gdk/gdk.c */


/*  Return a pointer to the vbox of a dialog. 
 *  Useful for adding widgets to dialogs. For example,
 *  if you need a dialog with text entry capability. 
 */
GtkWidget *
gtk_adds_dialog_vbox (GtkWidget *dialog)
{
  return GTK_DIALOG(dialog)->vbox;
}

/*  Return a pointer to the popup_menu of a textview. 
 *  Useful if you need to add to the default textview menu
 *  on a populate-popup event. 
 */
GtkWidget *
gtk_adds_text_view_popup_menu (GtkWidget *text_view)
{
  return GTK_TEXT_VIEW(text_view)->popup_menu;
}

/* C programmers allocate iters on the stack. We use this.
   Free it with gtk-text-iter-free */
GtkTextIter *
gtk_adds_text_iter_new ()
{
  GtkTextIter example;
  return gtk_text_iter_copy(&example);
}

/* C programmers allocate iters on the stack. We use this.
   Free it with gtk-tree-iter-free */
GtkTreeIter *
gtk_adds_tree_iter_new ()
{
  GtkTreeIter example;
  return gtk_tree_iter_copy(&example);
}

int gtk_adds_widget_mapped_p (GtkWidget *wid)
{ 
    return ((GTK_WIDGET_FLAGS (wid) & GTK_MAPPED) != 0) ? 1 : 0;
}

int gtk_adds_widget_visible_p (GtkWidget *wid)
{ 
    return ((GTK_WIDGET_FLAGS (wid) & GTK_VISIBLE) != 0) ? 1 : 0;
}

GdkWindow * 
gtk_adds_widget_window (GtkWidget *wid)
{
    return wid->window;
}

GdkColor *
gtk_adds_color_new ()
{
    return ((GdkColor *)malloc(sizeof(GdkColor)));
}

void
gtk_adds_color_set_rgb (GdkColor* color, guint r, guint g, guint b)
{
    color->red = r;
    color->green = g;
    color->blue = b;
}

GdkDisplay *
gdk_display_open_default_libgtk_only_slime (void)
{
  GdkDisplay *display;

  g_return_val_if_fail (gdk_initialized, NULL);
  
  display = gdk_display_get_default ();
  g_warning ("1 Gtk_slime_display_open display = %d", display);
  if (display)
    return display;

  display = gdk_display_open (gdk_get_display_arg_name ());
  g_warning ("2 Gtk_slime_display_open display = %d", display);

  if (!display && _gdk_screen_number >= 0)
    {
      g_free (_gdk_display_arg_name);
      _gdk_display_arg_name = g_strdup (_gdk_display_name);
      
      display = gdk_display_open (_gdk_display_name);
    }
  g_warning ("3 Gtk_slime_display_open display display = %d", display);
  
  if (display)
    gdk_display_manager_set_default_display (gdk_display_manager_get (),
					     display);
  
  return display;
}

gboolean
gtk_init_check_slime (int      *argc,
		      char   ***argv)
{
    if (!gtk_parse_args (argc, argv)) {
	g_warning ("Gtk_init_check_slime: Couldn't parse args.");
	return FALSE;
    }
  return gdk_display_open_default_libgtk_only_slime () != NULL;
}








